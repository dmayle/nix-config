{ config, pkgs, inputs, ... }:

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

  services.gnome-keyring = {
    #enable = true;
    #components = [ "gpg" "pkcs11" "secrets" "ssh" ];
  };

  home.sessionVariables = {
    EDITOR = "vi";
    FLAKE_CONFIG_URI = "path:${config.home.homeDirectory}/src/nix-config#homeConfigurations.beast";
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = "nix-command flakes";
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };
  };

  nixpkgs.config = {
    android_sdk.accept_license = true;
    allowUnfree = true;
    cudaSupport = true;
  };

  # Better process inspection than top
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "${pkgs.btop}/share/btop/themes/solarized_light.theme";
      vim_keys = true;
    };
  };

  # I want less to use case-insensitive search by default
  programs.less = {
    enable = true;
    keys = ''
      #env
      LESS = -i -R
    '';
  };

  home.packages = with pkgs; [
    # Might not be permanent, but I find it useful
    gdb

    # Basic utilities
    file

    git

    # Usefull process tool
    killall

    # Try out obsidian notes
    #obsidian

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

    # Terminal session management
    tmux

    # Fantastic interface for breaking up commits into better units
    git-crecord

    # Volume control used when clicking waybar
    pavucontrol

    # Compression tools
    unzip
    p7zip
    unrar

    # Kubernetes tools
    kubectx
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
    userEmail = "douglas@mayle.org";
  };

  #
  # Add a systemd service for ssh-agent
  # systemd.user.services.ssh-agent = {
  #   Unit = {
  #     PartOf = [ "graphical-session.target" ];
  #     Description = "SSH key agent";
  #   };
  #   Install = {
  #     WantedBy = [ "sway-session.target" ];
  #   };
  #   Service = {
  #     type = "Simple";
  #     Environment = [ "SSH_AUTH_SOCK=%t/ssh-agent.socket" ];
  #     ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
  #     Restart = "always";
  #     RestartSec = 3;
  #   };
  # };

  # Speed up the mouse movement on my laptop
  xsession.initExtra = ''
    TOUCHPADID=$(xinput list | awk '/^..Virtual core pointer/,/^..Virtual core keyboard/ { FS="\t|id="; if (/Touchpad/) print $3 }')
    xinput set-prop $TOUCHPADID "libinput Accel Speed" 0.5
  '';

  # Configure solarized light color scheme for kitty
  programs.kitty = {
    enable = true;
    shellIntegration.mode = "no-cursor";
    extraConfig = ''
      cursor_shape block
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

      # Setup font size controls, For 8k 65", 18.0 is good, for 4k 65", 10.0 is good
      font_size 18.0
      map kitty_mod+0 set_font_size 18.0
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
