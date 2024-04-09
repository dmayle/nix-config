{ config, pkgs, inputs, ... }:
{
  imports = with inputs.self; [
    homeManagerRoles.virtual-machine
    homeManagerProfiles.neovim
    homeManagerProfiles.os-other-linux
    homeManagerProfiles.tmux
  ];

  home = rec {
    username = "douglas";
    stateVersion = "22.05";
    homeDirectory = "/home/${username}";
  };
}
