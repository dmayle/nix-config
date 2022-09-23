{ config, pkgs, inputs, ... }:
{
  imports = with inputs.self; [
    homeManagerRoles.desktop
    homeManagerProfiles.neovim
    homeManagerProfiles.os-other-linux
    homeManagerProfiles.tmux
  ];
}
