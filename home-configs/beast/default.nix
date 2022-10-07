{ config, pkgs, inputs, ... }:
{
  imports = with inputs.self; [
    homeManagerRoles.desktop
    homeManagerProfiles.fonts
    homeManagerProfiles.neovim
    homeManagerProfiles.sway
    homeManagerProfiles.tmux
  ];
}
