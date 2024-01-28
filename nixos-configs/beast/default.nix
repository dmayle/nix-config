{ pkgs, config, inputs, lib, ... }:

{
  imports = with inputs.self; [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.desktop
    inputs.self.nixosProfiles.docker
    inputs.self.nixosProfiles.virtualbox
    inputs.self.nixosProfiles.sound
    inputs.self.nixosProfiles.games
    inputs.self.nixosProfiles.cachix-cuda
    inputs.self.nixosProfiles.cachix-nixpkgs-wayland
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Add NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Setup the machine name
  networking.hostName = "beast";

  # Set your time zone and locale
  time.timeZone = "America/Los_Angeles";
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
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    modesetting.enable = true;
    nvidiaSettings = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
      vulkan-validation-layers
      mesa.drivers
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
      vulkan-validation-layers
      mesa.drivers
    ];
  };

  # Nvidia fixup
  services.xserver.deviceSection = ''
    Option "SidebandSocketPath" "/tmp"
  '';


  # TODO: move this to sound profile
  hardware.pulseaudio.support32Bit = true;

  # Configure keymap in X11
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "caps:swapescape";
  services.xserver.xkbVariant = "extd";
  services.xserver.xkbModel = "pc105";
  services.xserver.libinput.enable = true;
  services.xserver.enable = true;

  services.xserver.resolutions = [{ x = 7680; y = 4320; }];
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false;
  };

  # We enable desktop managers in order to setup a graphical login with gnome
  # and sway. We want those to be configured by home-manager, so we'll have to
  # fixup this config a bit
  services.xserver.desktopManager.gnome.enable = true;
  # This adds a sway session to gdm, but the session just selects sway from the
  # current environment. My home manager config will override that version, so
  # all config should be done there.
  programs.xwayland.enable = true;
  programs.sway = {
    enable = true;
  };

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
    extraGroups = [ "wheel" "audio" "sway" "video" "i2c" "docker" "vboxusers" ];
  };
  nix.settings.allowed-users = [ "@wheel" ];

  # Some basic packages I want available if I use the system as root
  environment.systemPackages = with pkgs; [
    xorg.libpciaccess
    wget
    git
    file
    canon-cups-ufr2
    gnomeExtensions.gtile
  ];

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  # Very basic neovim config for root because vanilla vim is frustrating when
  # unconfigured
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

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

  # Prefer the network firewall
  networking.firewall.enable = false;

  system.stateVersion = "22.05"; # Did you read the comment?
}
