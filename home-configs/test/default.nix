{ config, pkgs, inputs, ... }:
{
  imports = [
    #inputs.self.homeRoles.desktop
    inputs.self.homeManagerProfiles.fonts
    inputs.self.homeManagerProfiles.neovim
    inputs.self.homeManagerProfiles.sway
    inputs.self.homeManagerProfiles.tmux
  ];
}
