{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.self.homeManagerRoles.desktop
    inputs.self.homeManagerProfiles.fonts
    inputs.self.homeManagerProfiles.neovim
    inputs.self.homeManagerProfiles.os-other-linux
    inputs.self.homeManagerProfiles.sway
    inputs.self.homeManagerProfiles.tmux
  ];
}
