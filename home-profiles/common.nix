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

  # Use GnuPG for signing and encryption
  programs.gpg = {
    enable = true;
    mutableKeys = true;
  };
  services.gpg-agent = {
    enable = true;
    enableBashIntegration = true;
    pinentryPackage = pkgs.pinentry-curses;
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

    # Per-directory dev setup
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

    # Compression tools
    unzip
    p7zip
    unrar

    # Kubernetes tools
    kubectx

    # Hetzner tools
    hcloud

    # Secret management
    sops
    ssh-to-age
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
    diff-so-fancy = {
      enable = true;
    };
    extraConfig = {
      pull = {
        rebase = true;
      };
    };
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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
}
