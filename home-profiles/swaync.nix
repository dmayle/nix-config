{ config, pkgs, lib, ... }:

{
  systemd.user.services.swaync = {
    Unit = {
      Description = "GTK-based wayland notification daemon";
      Documentation = "man:swaync(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
      ExecReload = "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-config ; ${pkgs.swaynotificationcenter}/bin/swaync-client  --reload-css";
      Restart = "on-failure";
    };
  };
  xdg.configFile."swaync/style.css" = {
    onChange = ''
      ${pkgs.procps}/bin/pidof swaync && ${pkgs.swaynotificationcenter}/bin/swaync-client --reload-css
    '';
    text = ''
      /* Solarized */
      @define-color base03 #002b36;
      @define-color base02 #073642;
      @define-color base01 #586e75;
      @define-color base00 #657b83;
      @define-color base0 #839496;
      @define-color base1 #93a1a1;
      @define-color base2 #eee8d5;
      @define-color base3 #fdf6e3;
      @define-color yellow #b58900;
      @define-color orange #cb4b16;
      @define-color red #dc322f;
      @define-color magenta #d33682;
      @define-color violet #6c71c4;
      @define-color blue #268bd2;
      @define-color cyan #2aa198;
      @define-color green #859900;

      /* Redefine SwayNC colors using solarized */
      @define-color cc-bg alpha(@base03, 0.7);
      @define-color noti-border-color alpha(@base3, 0.15);
      @define-color noti-bg @base02;
      @define-color noti-bg-opaque @base02;
      @define-color noti-bg-darker @base03;
      @define-color noti-bg-hover @magenta;
      @define-color noti-bg-hover-opaque @magenta;
      @define-color noti-bg-focus @base3;
      @define-color noti-close-bg alpha(@base1, 0.1);
      @define-color noti-close-bg-hover alpha(@base1, 0.15);
      @define-color text-color @base3;
      @define-color text-color-disabled @base1;
      @define-color bg-selected @blue;
    '';
  };
  home.packages = with pkgs; [
    # Required to allow default configs to work
    swaynotificationcenter
  ];
}
