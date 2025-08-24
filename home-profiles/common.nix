{
  config,
  pkgs,
  inputs,
  ...
}:

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

  # Variables to set when not using bash
  home.sessionVariables = {
    EDITOR = "nvim";
    FLAKE_CONFIG_URI = "path:${config.home.homeDirectory}/src/nix-config#homeConfigurations.$(hostname)";
  };

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
    };
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config = {
    android_sdk.accept_license = true;
    allowUnfree = true;
  };

  # Better process inspection than top
  programs.btop = {
    enable = true;
    settings = {
      vim_keys = true;
    };
  };

  # I want less to use case-insensitive search by default
  programs.less = {
    enable = true;
    config = ''
      #env
      LESS = -i -R
    '';
  };

  # Use GnuPG for signing and encryption
  programs.gpg = {
    enable = true;
    mutableKeys = true;
  };
  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  # Use stylix for theming
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/solarized-light.yaml";
    targets = {
      waybar.enable = false;
      gtk.extraCss = ''
        .thunar { font-size: 18pt; }
      '';
    };
  };

  home.packages = with pkgs; [
    # Basic utilities
    file
    lsof
    pciutils
    usbutils
    unixtools.netstat

    # Usefull process tool
    killall

    # Try out obsidian notes
    #obsidian

    # Easier to read diffs
    colordiff

    # Linux tools to learn
    fzf
    ripgrep
    mcfly
    fd

    # Terminal session management
    tmux

    # Compression tools
    unzip
    p7zip
    unrar

    # Secret management
    sops
    ssh-to-age
  ];

  programs.dircolors = {
    enable = true;
    enableBashIntegration = true;
  };
}
