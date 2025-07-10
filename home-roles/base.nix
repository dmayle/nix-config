{ inputs, ... }:
{
  imports = with inputs.self.homeManagerProfiles; [
    bash
  ];
}
