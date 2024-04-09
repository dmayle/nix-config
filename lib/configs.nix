{ inputs, lib, ... }:

let
  inherit (builtins) readFile;
  inherit (lib) removeSuffix;
in
rec {
  # Import pkgs with the supplied configuration, system, and overlays
  configurePackagesForSystem = pkgs: config: overlays: system:
    import pkgs {
      localSystem = { inherit system; };
      inherit config overlays;
    };

  # Read out a system file from the given path and return the contents
  systemForConfig = config: removeSuffix "\n" (readFile (config + "/system"));

  # Load the module as a Home Manager configuration
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

  # Load the module as a Nixos configuration
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
