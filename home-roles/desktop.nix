{ inputs, ... }: {
  imports = with inputs.self.homeManagerModules; with inputs.self.homeManagerProfiles; [
    ./base.nix

    common
    gui-common
  ];
}
