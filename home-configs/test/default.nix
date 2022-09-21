{ config, pkgs, inputs, ... }:
{
  imports = [
    #inputs.self.homeRoles.desktop
    inputs.self.homeProfiles.fonts
    inputs.self.homeProfiles.neovim
    inputs.self.homeProfiles.sway
    inputs.self.homeProfiles.tmux
  ];
}
