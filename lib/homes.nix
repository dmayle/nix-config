{ inputs, lib, flib, ... }:

let sys = "x86_64-linux";
in
{
  mkHomeConfig = systemPackages: extraArgs: config:
    let
      system = lib.removeSuffix "\n" (builtins.readFile (config + "/system"));
    in inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = systemPackages.${system};
      modules = [
        (import (config))
      ];
      # Only used for importable arguments
      extraSpecialArgs = extraArgs;
    };
}
