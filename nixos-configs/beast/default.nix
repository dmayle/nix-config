{ pkgs, config, inputs, lib, ... }:

{
  imports = with inputs.self; [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.desktop
    inputs.self.nixosProfiles.sound
    inputs.self.nixosProfiles.games
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  networking.hostName = "beast";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  # Configure keymap in X11
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "caps:swapescape";
  services.xserver.xkbVariant = "extd";
  services.xserver.xkbModel = "pc105";
  services.xserver.libinput.enable = true;
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };
  #services.xserver.extraConfig = "";
  #services.xserver.extraDisplaySettings = "";
  #services.xserver.extraLayouts.foo = {};
  services.xserver.deviceSection = ''
    Option "SidebandSocketPath" "/tmp"
  '';
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  users.users.douglas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "sway" "video" "i2c" ];
  };
  nix.settings.allowed-users = [ "@wheel" ];
  environment.systemPackages = with pkgs; [
    xorg.libpciaccess
    wget
    git
    file
  ];
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };
  environment.etc.inputrc.text = lib.mkAfter ''
    set editing-mode vi
    set keymap vi
  '';
  environment.variables.EDITOR = "nvim";
  services.openssh = {
    enable = true;
    forwardX11 = true;
  };

  networking.firewall.enable = false;

  system.stateVersion = "22.05"; # Did you read the comment?
}
