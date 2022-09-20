{ inputs, ... }: {
  imports = with inputs.self.homeManagerModules; with inputs.self.homeManagerProfiles; [
    git
  ]
}
