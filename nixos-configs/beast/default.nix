{ config, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.desktop
    inputs.self.nixosProfiles.sound
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Americas/Los_Angeles";
}
