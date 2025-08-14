{ inputs, ... }:
{
  imports = with inputs.self.nixosProfiles; [
    common
  ];

  # Required to support sway configuration in home manager
  security.polkit.enable = true;
}
