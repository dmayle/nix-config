{ inputs, ... }:
{
  imports = with inputs.self.homeManagerProfiles; [
    ./base.nix

    common
    gui-common
  ];
}
