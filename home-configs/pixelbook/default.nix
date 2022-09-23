{ config, pkgs, inputs, ... }:
{
  imports = with inputs.self; [
    homeManagerRoles.virtual-machine
    homeManagerProfiles.neovim
    homeManagerProfiles.os-other-linux
    homeManagerProfiles.tmux
  ];
}
