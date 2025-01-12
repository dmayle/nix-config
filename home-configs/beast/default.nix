{ inputs, ... }:
{
  imports = with inputs.self; [
    homeManagerRoles.desktop
    homeManagerProfiles.dev
    homeManagerProfiles.fonts
    homeManagerProfiles.games
    homeManagerProfiles.hyprland
    homeManagerProfiles.jupyterlab
    homeManagerProfiles.neovim
    homeManagerProfiles.swaync
    # homeManagerProfiles.syncthing
    homeManagerProfiles.three_d_printing
    homeManagerProfiles.tmux
    homeManagerProfiles.wayland
  ];

  home = rec {
    username = "douglas";
    stateVersion = "22.05";
    homeDirectory = "/home/${username}";
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-battery-timeout = 0;
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = [];
      switch-applications-backwards = [];
      switch-windows = ["<Alt>Tab"];
      switch-windows-backwards = ["<Shift><Alt>Tab"];
    };
  };
}
