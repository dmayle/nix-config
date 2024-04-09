{ config, pkgs, inputs, ... }:
{
  imports = with inputs.self; [
    homeManagerRoles.desktop
    homeManagerProfiles.fonts
    homeManagerProfiles.neovim
    homeManagerProfiles.os-other-linux
    homeManagerProfiles.sway
    homeManagerProfiles.tmux
  ];

  home = rec {
    username = "douglas";
    stateVersion = "22.05";
    homeDirectory = "/home/${username}";
  };
}
