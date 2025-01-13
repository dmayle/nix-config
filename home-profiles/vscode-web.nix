{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Visual Studio for Stephanie
    vscode-fhs
  ];

  systemd.user.services.vscode = {
    Unit = {
      Description = "Visual Studio Code Web";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      #Environment = "PATH=${pkgs.kmod}/bin:${pkgs.gnugrep}/bin";
      ExecStart = "${pkgs.vscode-fhs}/bin/code serve-web --without-connection-token --host=0.0.0.0 --port=4000";
      Restart = "always";
      RestartSec = 3;
    };
  };
}
