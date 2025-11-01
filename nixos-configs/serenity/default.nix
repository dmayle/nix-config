{
  pkgs,
  modulesPath,
  config,
  inputs,
  lib,
  ...
}:

{
  imports = with inputs.self; [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware-configuration.nix
    ./disk-config.nix
    nixosRoles.desktop
    nixosProfiles.ai
    nixosProfiles.docker
    nixosProfiles.virtualbox
    nixosProfiles.sound
    nixosProfiles.games
    nixosProfiles.cachix-cuda
    nixosProfiles.cachix-devenv
    nixosProfiles.cachix-nixpkgs-wayland
    nixosProfiles.prometheus
    nixosProfiles.web-servers
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Add NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Setup the machine name
  networking.hostName = "serenity";

  # Set your time zone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Basic console configuration supporting latin languages
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Setup the hardware to use nvidia drivers, and ensure hardware acceleration
  # support for wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.production;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    modesetting.enable = true;
    nvidiaSettings = true;
    open = true;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      cudaPackages.cudatoolkit
      libvdpau-va-gl
      mesa
      nvidia-vaapi-driver
      vaapiVdpau
      vulkan-validation-layers
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libvdpau-va-gl
      mesa
      nvidia-vaapi-driver
      vaapiVdpau
      vulkan-validation-layers
    ];
  };

  # Enable SMU for system monitoring
  hardware.cpu.amd.ryzen-smu.enable = true;

  # Nvidia fixup
  services.xserver.deviceSection = ''
    Option "SidebandSocketPath" "/tmp"
  '';

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    options = "caps:swapescape";
    variant = "extd";
    model = "pc105";
  };
  services.libinput.enable = true;

  services.xserver.enable = true;
  services.xserver.resolutions = [
    {
      x = 7680;
      y = 4320;
    }
  ];
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false;
  };

  # We enable desktop managers in order to setup a graphical login with gnome
  # and hyprland. We want those to be configured by home-manager, so we'll have
  # to fixup this config a bit
  services.desktopManager.gnome.enable = true;
  # This adds a hyprland session to gdm, but the session just selects hyprland
  # from the current environment. My home manager config will override that
  # version, so all config should be done there.
  programs.xwayland.enable = true;
  programs.hyprland.enable = true;

  # Enabling desktop managers forces xdg-desktop-portal (services for sandboxed
  # applications) to be configured. We want to configure this at the
  # home-manager level, so we forcibly disable it here.
  xdg.portal.enable = lib.mkForce false;

  # TODO: move this to desktop profile
  # This is a desktop machine we don't want turning off so that we can access
  # it from the network
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  users.users.douglas = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "docker"
      "i2c"
      "plugdev"
      "sway"
      "vboxusers"
      "video"
      "wheel"
    ];
    hashedPasswordFile = config.sops.secrets."users/douglas".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgeON0VkK4mu9XOalV1Alp5vFztuhT8T/g75JpJjFwe douglas@beast"
    ];
  };
  nix.settings.allowed-users = [ "@wheel" ];

  # RGB Control
  services.hardware.openrgb.enable = true;

  # Setup sops
  sops = {
    defaultSopsFile = ../../secrets/serenity.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "ttyd/username" = { };
      "ttyd/password" = { };
      "ai_tokens/hugging_face" = { };
      "users/douglas".neededForUsers = true;
    };
  };

  # Some basic packages I want available if I use the system as root
  environment.systemPackages = with pkgs; [
    xorg.libpciaccess
    wget
    git
    file
    canon-cups-ufr2
    gnomeExtensions.gtile
    # Adds udev rules for access to QMK keyboards
    qmk
    via
    # RGB Control
    openrgb-with-all-plugins
    # Ryzen SMU monitor
    ryzen-monitor-ng
  ];

  # Allow via (and http://usevia.app) to access hidraw devices for updating/flashing
  hardware.keyboard.qmk.enable = true;
  # services.udev.extraRules = ''
  #   KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  # '';
  services.udev.packages = with pkgs; [ via ];

  # Very basic neovim config for root because vanilla vim is frustrating when
  # unconfigured
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  programs.nix-ld.enable = true;

  environment.variables.EDITOR = "nvim";
  environment.etc.inputrc.text = lib.mkAfter ''
    set editing-mode vi
    set keymap vi
  '';

  # Ensure that nix-* (e.g. nix-shell) use the same nixpkgs as this flake
  environment.etc."nixpath/nixpkgs".source = inputs.nixpkgs;
  nix.nixPath = [
    "nixpkgs=/etc/nixpath/nixpkgs"
  ];

  # Enable remote access
  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };

  # Disable the internal network firewall
  networking.firewall.enable = false;

  system.stateVersion = "22.05"; # Did you read the comment?
}
