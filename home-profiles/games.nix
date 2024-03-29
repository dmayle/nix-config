{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    joycond-cemuhook
    ryujinx
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
      Type = "simple";
      Environment = "PATH=${pkgs.kmod}/bin:${pkgs.gnugrep}/bin";
      ExecStart = "${pkgs.joycond-cemuhook}/bin/joycond-cemuhook";
      Restart = "always";
      RestartSec = 3;
    };
  };
}
