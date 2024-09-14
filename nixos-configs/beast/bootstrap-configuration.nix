# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Set your time zone.
  time.timeZone = "Americas/New_York";
  networking.hostName = "beast";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Configure keymap in X11
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "caps:swapescape";
  services.xserver.xkbVariant = "extd";
  services.xserver.xkbModel = "pc105";
  services.xserver.libinput.enable = true;
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
    wget
    git
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
  services.openssh.enable = true;

  networking.firewall.enable = false;

  system.copySystemConfiguration = true;
  system.stateVersion = "22.05"; # Did you read the comment?
}
