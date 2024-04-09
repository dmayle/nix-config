{ inputs, lib, ... }:

{
  mkHomeConfig = systemPackages: extraSpecialArgs: config:
    let
      system = lib.removeSuffix "\n" (builtins.readFile (config + "/system"));
    in inputs.home-manager.lib.homeManagerConfiguration {
      inherit extraSpecialArgs;

      pkgs = systemPackages.${system};

      modules = [
        (import (config))
      ];
    };

  mkNixosConfig = systemPackages: specialArgs: config:
    let
      system = lib.removeSuffix "\n" (builtins.readFile (config + "/system"));
    in lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        (import (config))
        { nixpkgs.pkgs = systemPackages.${system}; }
      ];
    };
}
