{ inputs, lib, flib, ... }:

let sys = "x86_64-linux";
in
{
  mkHomeConfig = defaults: systemPackages: extraArgs: path:
    let
      system = lib.removeSuffix "\n" (builtins.readFile (path + "/system"));
    in inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = systemPackages.${system};
      modules = [
        { _module.args = { inherit flib; }; }
        (import (path))
        defaults
      ];
      # Only used for importable arguments
      extraSpecialArgs = extraArgs;
    };
}
