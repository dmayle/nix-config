{ inputs, pkgs, ... }:
{
  imports =
    with inputs.self.nixosModules;
    with inputs.self.nixosProfiles;
    [
      ./base.nix

      sound
    ];

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.canon-cups-ufr2 ];
  #services.avahi.enable = true;
  #services.avahi.nssmdns4 = true;
}
