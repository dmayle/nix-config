{ config, pkgs, lib, ... }:

{

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Setup vi keybinding with readline
  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      set keymap vi
    '';
  };

  home.sessionVariables = {
    EDITOR = "vi";
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = "nix-command flakes";
  };

  home.packages = with pkgs; [
    # List of packages that may need to be inherited from a non-nixos OS
    # git # Has custom protocol

    # Easier to read diffs
    colordiff

    # Source code indexing for non-google3 code
    universal-ctags

    # Per-directory setup (handles pyenv)
    direnv

    # Linux tools to learn
    fzf
    ripgrep
    mcfly
    fd

    # Better process inspection than top
    htop

    # Terminal session management
    tmux

    # Fantastic interface for breaking up commits into better units
    git-crecord

    # Volume control used when clicking waybar
    pavucontrol

    # Android studio for... android development
    android-studio
  ];

  programs.dircolors = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.writeTextDir "/git" "";
    userName = "Douglas Mayle";
    userEmail = "dougle@google.com";
  };

  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" "erasedups" ];
    historyFileSize = 20000;
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

  # Add a systemd service for ssh-agent
  systemd.user.services.ssh-agent = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      Description = "SSH key agent";
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
    Service = {
      type = "Simple";
      Environment = [ "SSH_AUTH_SOCK=%t/ssh-agent.socket" ];
      ExecStart = "ssh-agent -D -a $SSH_AUTH_SOCK";
      Restart = "always";
      RestartSec = 3;
    };
  };

  # Speed up the mouse movement on my laptop
  xsession.initExtra = ''
    TOUCHPADID=$(xinput list | awk '/^..Virtual core pointer/,/^..Virtual core keyboard/ { FS="\t|id="; if (/Touchpad/) print $3 }')
    xinput set-prop $TOUCHPADID "libinput Accel Speed" 0.5
  '';

  # Configure solarized light color scheme for kitty
  programs.kitty = {
    enable = true;
    extraConfig = ''
      enable_audio_bell no
      # Solarized Light Colorscheme

      background              #fdf6e3
      foreground              #657b83
      cursor                  #586e75

      selection_background    #475b62
      selection_foreground    #eae3cb

      color0                #073642
      color8                #002b36

      color1                #dc322f
      color9                #cb4b16

      color2                #859900
      color10               #586e75

      color3                #b58900
      color11               #657b83

      color4                #268bd2
      color12               #839496

      color5                #d33682
      color13               #6c71c4

      color6                #2aa198
      color14               #93a1a1

      color7                #eee8d5
      color15               #fdf6e3

      # Setup font size controls
      font_size 10.0
      map kitty_mod+0 set_font_size 10.0
      map kitty_mod+equal change_font_size all +2.0
      map kitty_mod+minus change_font_size all -2.0
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
}
