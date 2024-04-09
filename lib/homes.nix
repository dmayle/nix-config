{ inputs, lib, ... }:

let
  inherit (builtins) readFile;
  inherit (lib) removeSuffix;
in
rec {
  configurePackagesForSystem = pkgs: config: overlays: system:
    import pkgs {
      localSystem = { inherit system; };
      inherit config overlays;
    };

  # Read out a system file from the given path and return the contents
  systemForConfig = config: removeSuffix "\n" (readFile (config + "/system"));

  mkHomeConfig = systemPackages: extraSpecialArgs: config:
    let
      system = systemForConfig config;
    in inputs.home-manager.lib.homeManagerConfiguration {
      inherit extraSpecialArgs;

      pkgs = systemPackages.${system};

      modules = [
        (import (config))
      ];
    };

  mkNixosConfig = systemPackages: specialArgs: config:
    let
      system = systemForConfig config;
    in lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        (import (config))
        { nixpkgs.pkgs = systemPackages.${system}; }
      ];
    };
}
