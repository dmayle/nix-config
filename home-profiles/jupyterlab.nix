{ pkgs, devShells, ... }:

let
  myJupyter = pkgs.jupyter.override {
    definitions = {
      # python_msdoc = let python_msdoc = (builtins.head devShells.x86_64-linux.python_msdoc.nativeBuildInputs); in {
      #   displayName = "Python MSDoc";
      #   language = "python";
      #   logo32 = "${pkgs.jupyter.sitePackages}/ipykernel/resources/logo-32x32.png";
      #   logo64 = "${pkgs.jupyter.sitePackages}/ipykernel/resources/logo-64x64.png";
      #   argv = [
      #     "${python_msdoc}/bin/python"
      #     "-m"
      #     "ipykernel_launcher"
      #     "-f"
      #     "{connection_file}"
      #   ];
      # };
      python_torch =
        let
          python_torch = (builtins.head devShells.x86_64-linux.python_torch.nativeBuildInputs);
        in
        {
          displayName = "PyTorch";
          language = "python";
          # I don't like this absolute reference, but it's not too big of a deal.
          # I should fix it at somem point
          logo32 = "${pkgs.python313Packages.ipykernel}/lib/python3.13/site-packages/ipykernel/resources/logo-32x32.png";
          logo64 = "${pkgs.python313Packages.ipykernel}/lib/python3.13/site-packages/ipykernel/resources/logo-64x64.png";
          argv = [
            "${python_torch}/bin/python"
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
      Type = "simple";
      ExecStart = "${myJupyter}/bin/jupyter-lab --ip=0.0.0.0 --no-browser";
      Restart = "always";
      RestartSec = 3;
    };
  };
}
