{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    joycond_cemuhook
    (lutris.override {
      extraLibraries = pkgs: [
        SDL2_net
        opusfile
      ];
    })
  ];

  systemd.user.services.joycond-cemuhook = {
    Unit = {
      Description = "Joycon Gyro Adapter";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      type = "Simple";
      ExecStart = "${pkgs.joycond_cemuhook}/bin/joycond-cemuhook";
      Restart = "always";
      RestartSec = 3;
    };
  };
}
