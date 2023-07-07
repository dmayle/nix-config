{ config, pkgs, lib, ... }:

{
  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" "erasedups" ];
    historyFileSize = 20000;
    shellAliases = {
      set4k = "xrandr --output HDMI-0 --mode 3840x2160 --refresh 119.88 --scale 1x1";
      set8k = "xrandr --output HDMI-0 --mode 7680x4320 --refresh 59.94 --scale 0.75x0.75";
    };
    # Still need to setup prompt.rc
    initExtra = ''
      # Command hashing is used by various shell scripts, so enable it
      set -h

      # A number of support functions to make tmux work the way I want it to
      function _inside_local_tmux() {
        if [ -n "$TMUX" ]; then
          return 0 # TRUE
        fi;
        return 1 # FALSE
      }

      function _inside_any_tmux() {
        case "$TERM" in
        screen*|tmux*)
          return 0 # TRUE
        esac
        return 1 # FALSE
      }

      function _get_tmux_socket() {
        if [ -z "$TMUX" ]; then
          return
        fi;
        echo $(basename $(command tmux display-message -p '#{socket_path}'))
      }

      function _ensure_tmux_socket() {
        command tmux -L "$1" -f ${config.xdg.configHome}/tmux/tmux-''${1}.conf list-sessions &> /dev/null && return
        tmux -L "$1" -f ${config.xdg.configHome}/tmux/tmux-''${1}.conf new -d -t group -s 0
      }

      function _ensure_tmux_free_session() {
        if [ -z "$1" ]; then
          _TMUX_SOCKET=$(_get_tmux_socket)
        else
          _TMUX_SOCKET="$1"
        fi;

        # Let's get a bash array variable containing all of the sessions on this tmux socket
        unset _SESSIONS
        while IFS= read -r _line; do _SESSIONS+=("$_line"); done <<< "$(command tmux -L $_TMUX_SOCKET list-sessions -F '#S#{?session_attached,(attached),}' 2>/dev/null)"

        # If there is an unattached session, we're done, otherwise create a new
        # session with MAX_VALUE+1
        _MAX_SESSION_NUM=-1
        for _SESSION in "''${_SESSIONS[@]}"; do
          if [[ "''${_SESSION}" == "''${_SESSION%(attached)}" ]]; then
            # The existing sessions isn't attached so our job is done
            return
          fi;

          if [[ ''${_SESSION%(attached)} -gt ''${_MAX_SESSION_NUM} ]]; then
            _MAX_SESSION_NUM="''${_SESSION%(attached)}"
          fi
        done

        # All sessions already attached, so add a new one
        command tmux -L "$_TMUX_SOCKET" new -d -t group -s $((_MAX_SESSION_NUM + 1))
      }

      function _join_tmux_socket() {
        if [ -z "$1" ]; then
          _TMUX_SOCKET=$(_get_tmux_socket)
        else
          _TMUX_SOCKET="$1"
        fi;

        # Let's get a bash array variable containing all of the sessions on this tmux socket
        unset _SESSIONS
        while IFS= read -r _line; do _SESSIONS+=("$_line"); done <<< "$(command tmux -L $_TMUX_SOCKET list-sessions -F '#S#{?session_attached, (attached),}' 2>/dev/null)"

        # Find the first unattached sessions and join it
        for _SESSION in "''${_SESSIONS[@]}"; do
          if [[ "''${_SESSION}" == "''${_SESSION%(attached)}" ]]; then
            # The existing sessions isn't attached so join it
            command tmux -L "$_TMUX_SOCKET" attach -t "$_SESSION"
            return
          fi;
        done
      }

      function tmux() {
        # This function doesn't take arguments, so instead call the underlying tmux
        if [ $# != 0 ]; then
          command tmux "$@"
          return;
        fi;

        if _inside_any_tmux; then
          if _inside_local_tmux; then
            TMUX_SOCKET=$(_get_tmux_socket)
            if [ "$TMUX_SOCKET" = "inner" ]; then
              echo Already inside of TMUX
              return;
            fi;
          fi;
          _ensure_tmux_socket inner
          _ensure_tmux_free_session inner
          _join_tmux_socket inner
          return;
        fi;

        _ensure_tmux_socket outer
        _ensure_tmux_free_session outer
        _join_tmux_socket outer
      }

      function ensure() {
        gcertstatus || gcert && ssh -t atuin.c.googlers.com bash -c 'gcertstatus || gcert'
      }

      # SSH works best with an agent, so first attempt to find and connect to
      # an existing agent, and if needed, start one up. `gnome-keyring-daemon`
      # can handle ssh agent duties, but it can't handle the key types we use
      # on corp, so we don't use it.
      function _ssh_socket_works() {
        if env SSH_AUTH_SOCK=$1 ssh-add -l &>/dev/null; then
          return 0 # TRUE
        fi;
        return 1 # FALSE
      }

      function _found_working_ssh_agent() {
        # Check existing environment
        if [ -n "$SSH_AUTH_SOCK" ] && _ssh_socket_works "$SSH_AUTH_SOCK"; then
          return 0 # TRUE
        fi

        # Check systemd user service ssh-agent
        if _ssh_socket_works ''${XDG_RUNTIME_DIR}/ssh-agent.socket; then
          export SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR}/ssh-agent.socket
          return 0 # TRUE
        fi

        # SSH Agent socket locations/patterns:
        # ~/.cache/agent-tty (console agent, no GUI)
        # $DIR/ssh-agent.XXXXXXXXXX/agent
        for agent in $(ls {{/tmp,/var/run/ssh-agent}/ssh-*,''${XDG_CACHE_DIR:-$HOME/.cache},$XDG_RUNTIME_DIR}/{ssh-,}agent{,.*,-tty}{,.socket} 2>/dev/null); do
          if _ssh_socket_works $agent; then
            export SSH_AUTH_SOCK="$agent"
            return 0 # TRUE
          fi
        done

        return 1 # FALSE
      }

      function _start_ssh_agent() {
        if systemctl --user list-unit-files ssh-agent.service &>/dev/null; then
          systemctl --user restart ssh-agent.service
          if _ssh_socket_works ''${XDG_RUNTIME_DIR}/ssh-agent.socket; then
            export SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR}/ssh-agent.socket
            return
          fi
        fi

        echo Starting manual ssh-agent session
        eval $(ssh-agent)
        ssh-add
      }

      ssh-reagent () {
        if _found_working_ssh_agent; then
          return
        fi

        echo Cannot find ssh agent - restarting...

        _start_ssh_agent
      }
      ssh-reagent

      [[ -f ~/src/dotfiles/bash/prompt.rc ]] && source ~/src/dotfiles/bash/prompt.rc
    '';
  };
}
