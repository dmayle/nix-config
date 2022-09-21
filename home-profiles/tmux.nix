{ config, ... }:

{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    clock24 = true;
    keyMode = "vi";
    shortcut = "a";
    extraConfig = ''
      # Use tmux TERM for more features, and 256color for true color
      set -g default-terminal "tmux-256color"

      # Enable italic support
      #set -as terminal-overrides ',*:sitm=\E[3m'

      # Enable undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'

      # Enable colored underline support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # This tmux statusbar config was created by tmuxline.vim
      # on Fri, 14 Feb 2020

      set -g status-justify "left"
      set -g status "on"
      set -g status-left-style "none"
      set -g message-command-style "fg=#eee8d5,bg=#93a1a1"
      set -g status-right-style "none"
      set -g pane-active-border-style "fg=#657b83"
      set -g status-style "none,bg=#eee8d5"
      set -g message-style "fg=#eee8d5,bg=#93a1a1"
      set -g pane-border-style "fg=#93a1a1"
      set -g status-right-length "100"
      set -g status-left-length "100"
      setw -g window-status-activity-style "none"
      setw -g window-status-separator ""
      setw -g window-status-style "none,fg=#93a1a1,bg=#eee8d5"
      set -g status-left "#[fg=#eee8d5,bg=#657b83,bold] #S #[fg=#657b83,bg=#eee8d5,nobold,nounderscore,noitalics]"
      set -g status-right "#[fg=#93a1a1,bg=#eee8d5,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#93a1a1] %Y-%m-%d  %H:%M #[fg=#657b83,bg=#93a1a1,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#657b83] #h "
      setw -g window-status-format "#[fg=#93a1a1,bg=#eee8d5] #I #[fg=#93a1a1,bg=#eee8d5] #W "
      setw -g window-status-current-format "#[fg=#eee8d5,bg=#93a1a1,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#93a1a1] #I #[fg=#eee8d5,bg=#93a1a1] #W #[fg=#93a1a1,bg=#eee8d5,nobold,nounderscore,noitalics]"
    '';
  };
  xdg.configFile."tmux/tmux-outer.conf".text = ''
    # Outer tmux config

    source-file ${config.xdg.configHome}/tmux/tmux-shared.conf

    # Use Ctrl-backspace as outer prefix
    set -g prefix 'C-\'
    bind 'C-\' last-window

    # The outer window uses backtick to allow sending Ctrl-backspace
    bind ` send-prefix

    # Setup config reloading
    bind r source-file ${config.xdg.configHome}/tmux/tmux-outer.conf \; display-message "Config reloaded."

    set -g status-bg black
    set -g status-fg yellow
    # set -g status-attr default
    # set-window-option -g window-status-fg brightblue
    # set-window-option -g window-status-bg default
    # set-window-option -g window-status-attr dim
    # set-window-option -g window-status-current-fg brightred
    # set-window-option -g window-status-current-bg default
    set-option -g status-position top
    # set-option -g pane-border-fg black
    # set-option -g pane-active-border-fg brightgreen
    # set-option -g message-bg black
    #set-option -g message-fg brightred
    set-option -g display-panes-active-colour blue
    set-option -g display-panes-colour brightred
    set-window-option -g clock-mode-colour green
    set-window-option -g window-status-bell-style fg=black,bg=red
    #run-shell -b "tmux send-keys tmux Enter"
    set-option -g status-format[0] '#{W:#{?#{e|<:#{window_index},#{active_window_index}},#[align=left #{window-status-style}],#{?#{e|==:#{window_index},#{active_window_index}},#[align=centre #{window-status-activity-style}],#{?#{e|>:#{window_index},#{active_window_index}},#[align=right #{window-status-style}],}}}#{T:window-status-format}}'
    set-hook -g after-new-session "source-file ${config.xdg.configHome}/tmux/tmux-outer-session-setup.conf"
  '';
  xdg.configFile."tmux/tmux-outer-session-setup.conf".text = ''
    # Session setup (windows and splits) for outer tmux config

    rename-window laptop
    new-window -n atuin
    last-window
  '';
  xdg.configFile."tmux/tmux-inner.conf".text = ''
    # Inner tmux config

    source-file ${config.xdg.configHome}/tmux/tmux-shared.conf

    # Use GNU screen-style prefix
    set -g prefix C-a
    bind a send-prefix

    bind C-a last-window

    set-window-option -g window-status-bell-style fg=black,bg=red

    # This tmux statusbar config was created by tmuxline.vim
    # on Fri, 14 Feb 2020

    set -g status-justify "left"
    set -g status "on"
    set -g status-left-style "none"
    set -g message-command-style "fg=#eee8d5,bg=#93a1a1"
    set -g status-right-style "none"
    set -g pane-active-border-style "fg=#657b83"
    set -g status-style "none,bg=#eee8d5"
    set -g message-style "fg=#eee8d5,bg=#93a1a1"
    set -g pane-border-style "fg=#93a1a1"
    set -g status-right-length "100"
    set -g status-left-length "100"
    setw -g window-status-activity-style "none"
    setw -g window-status-separator ""
    setw -g window-status-style "none,fg=#93a1a1,bg=#eee8d5"
    set -g status-left "#[fg=#eee8d5,bg=#657b83,bold] #S #[fg=#657b83,bg=#eee8d5,nobold,nounderscore,noitalics]"
    set -g status-right "#[fg=#93a1a1,bg=#eee8d5,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#93a1a1] %Y-%m-%d  %H:%M #[fg=#657b83,bg=#93a1a1,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#657b83] #h "
    setw -g window-status-format "#[fg=#93a1a1,bg=#eee8d5] #I #[fg=#93a1a1,bg=#eee8d5] #W "
    setw -g window-status-current-format "#[fg=#eee8d5,bg=#93a1a1,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#93a1a1] #I #[fg=#eee8d5,bg=#93a1a1] #W #[fg=#93a1a1,bg=#eee8d5,nobold,nounderscore,noitalics]"
  '';
  xdg.configFile."tmux/tmux-shared.conf".text = ''
    # Shared tmux config

    # Way more scrollback buffer
    set -g history-limit 50000

    # Remove escape time delay for vim
    set -s escape-time 0

    # I use vi-mode always
    setw -g mode-keys vi

    # I connect from multiple sized terminals at same time
    setw -g aggressive-resize on

    # Support focus events
    set -g focus-events on

    # I like full color terminals
    set -g default-terminal "tmux-256color"

    # I think this is obsolete
    # set -ga terminal-overrides ",*256col*:Tc"

    # I don't yet know if I need this
    # Enable italic support
    #set -as terminal-overrides ',*:sitm=\E[3m'

    # Enable undercurl support
    set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'

    # Enable colored underline support
    set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

    # Use 24-hour clock
    setw -g clock-mode-style
  '';
}
