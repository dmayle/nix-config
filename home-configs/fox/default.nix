{ inputs, ... }:
{
  imports = with inputs.self; [
    homeManagerRoles.virtual-machine
    homeManagerProfiles.dev
    homeManagerProfiles.fonts
    homeManagerProfiles.neovim
    homeManagerProfiles.tmux
  ];

  home = rec {
    username = "douglas";
    stateVersion = "22.05";
    homeDirectory = "/home/${username}";
  };
}
