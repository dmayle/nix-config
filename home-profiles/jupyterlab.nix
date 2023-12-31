{ config, pkgs, lib, ... }:

let
  myJupyter = pkgs.jupyter.override {
    definitions = {
      clojure = pkgs.clojupyter.definition;
      custom = {
        displayName = "Python MSDoc";
        language = "python";
        logo32 = "${pkgs.jupyter.sitePackages}/ipykernel/resources/logo-32x32.png";
        logo64 = "${pkgs.jupyter.sitePackages}/ipykernel/resources/logo-64x64.png";
        argv = [
          # Actualized in devShell, need to figure out how to link this to that actual devShell
          "/nix/store/2864ar7vhhw1fn04jwl5cdj9c39ffswi-python3-3.11.6-env/bin/python"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
      };
    };
  };
in
{
  systemd.user.services.jupyter = {
    Unit = {
      Description = "Jupyter Lab Development Environment";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      type = "Simple";
      ExecStart = "${myJupyter}/bin/jupyter-lab";
      Restart = "always";
      RestartSec = 3;
    };
  };
}
