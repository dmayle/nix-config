{ config, pkgs, inputs, ... }:
{
  imports = with inputs.self; [
    homeManagerRoles.desktop
    homeManagerProfiles.3d_printing
    homeManagerProfiles.fonts
    homeManagerProfiles.games
    homeManagerProfiles.neovim
    homeManagerProfiles.sway
    homeManagerProfiles.tmux
  ];

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
