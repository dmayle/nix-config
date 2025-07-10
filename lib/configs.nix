{ inputs, lib, ... }:

let
  inherit (builtins) readFile;
  inherit (lib) removeSuffix;
in
rec {
  # Read out a system file from the given path and return the contents
  systemForConfig = config: removeSuffix "\n" (readFile (config + "/system"));

  # Import pkgs with the supplied configuration, system, and overlays
  mkPackages =
    pkgs: config: overlays: system:
    import pkgs {
      localSystem = { inherit system; };
      inherit config overlays;
    };

  # Load the module as a Home Manager configuration
  mkHomeConfig =
    systemPackages: extraSpecialArgs: name: config:
    let
      system = systemForConfig config;
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit extraSpecialArgs;

      pkgs = systemPackages.${system};

      modules = [
        (import (config))
      ];
    };

  # Load the module as a Nixos configuration
  mkNixosConfig =
    systemPackages: specialArgs: name: config:
    let
      system = systemForConfig config;
    in
    lib.nixosSystem {
      inherit system specialArgs;

      modules = [
        (import (config))
        { nixpkgs.pkgs = systemPackages.${system}; }
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
      ];
    };
}
