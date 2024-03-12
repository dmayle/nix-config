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
  home.packages = with pkgs; [
    # Required to allow default configs to work
    swaynotificationcenter
  ];
}
