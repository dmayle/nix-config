{ pkgs, ... }:

{
  home.packages = with pkgs; [
    joycond-cemuhook
    ryujinx

    # 64 and 32-bit Wine
    wineWowPackages.stable
    winetricks

    # For benchmarking
    furmark

    # For undervolting
    lact

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
