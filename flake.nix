{
  description = "dmayle's nix system configurations, both nixos and home-manager";

  # This is a collection of sources to have their versions and hashes managed
  # by this flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # Transient dependency, but I want it to use my nixpkgs
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nixpkgs-lib = {
      url = "github:nix-community/nixpkgs.lib";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.38.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.38.0";
      inputs.hyprland.follows = "hyprland";
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    vim-maximizer = {
      url = "github:szw/vim-maximizer";
      flake = false;
    };
    vim-glaive = {
      url = "github:google/vim-glaive";
      flake = false;
    };
    vim-syncopate = {
      url = "github:google/vim-syncopate";
      flake = false;
    };
    vim-fakeclip = {
      url = "github:kana/vim-fakeclip";
      flake = false;
    };
    NeoSolarized-nvim = {
      url = "github:Tsuzat/NeoSolarized.nvim";
      flake = false;
    };
  };

  # The output of this is my nixos configurations and home manager configurations
  outputs = inputs @ { self, systems, nixpkgs, ... }:
    # I need to setup three things in order for the code contained in this
    # flake to work properly:
    # 1) Import and setup library code which is used by my modules, but also by
    #    this flake to easily setup multiple configurations
    # 2) Import and setup code to be made available by my modules: packages,
    #    overlays, and mixins shared by different configurations
    # 3) Setup nixpkgs to enable unfree modules
    let
      inherit (flib) configurePackagesForSystem mapModules mkHomeConfig;

      eachSystem = nixpkgs.lib.genAttrs (import systems);

      lib = nixpkgs.lib;

      flib = import ./lib { inherit inputs lib; };

      # Load all modules only once
      allModules = flib.loadModules [
        ./dev-shells
        ./home-modules
        ./home-profiles
        ./home-roles
        ./home-configs
        ./overlays
        ./nixos-modules
        ./nixos-profiles
        ./nixos-roles
        ./nixos-configs
        ./packages
      ];

      # Global nixpkgs config used in this flake
      pkgConfig = {
        android_sdk.accept_license = true;
        allowUnfree = true;
        cudaSupport = true;
      };

      # Global nixpkgs overlays used in this flake, depends on x86_64-linux packages
      pkgOverlays = [
      ];

      # Curry new config and overlays into nixpkgs as per-system function
      pkgsForSystem = configurePackagesForSystem nixpkgs pkgConfig pkgOverlays;

      # Create an attrset of systems to nixpkgs for that system
      systemPackages = eachSystem (system: pkgsForSystem system);
    in

    rec {
      devShells = eachSystem (system:
        mapModules allModules.dev-shells (p: import p { pkgs = systemPackages.${system}; }));

      homeManagerModules = allModules.home-modules;

      homeManagerProfiles = allModules.home-profiles;

      homeManagerRoles = allModules.home-roles;

      nixosModules = allModules.nixos-modules;

      nixosProfiles = allModules.nixos-profiles;

      nixosRoles = allModules.nixos-roles;

      nixosConfigurations =
        let
          configs = builtins.attrNames allModules.nixos-configs;

          mkNixosConfig = name:
            let
              system = lib.removeSuffix "\n" (builtins.readFile (./nixos-configs + "/${name}/system"));
              pkgs = systemPackages.${system};
            in lib.nixosSystem {
              inherit system;
              modules = [
                (import (./nixos-configs + "/${name}"))
                { _module.args = { inherit flib; }; }
                { nixpkgs.pkgs = pkgs; }
              ];
              # Only used for importable arguments
              specialArgs = { inherit inputs; nix-colors = inputs.nix-colors; };
            };
        in lib.genAttrs configs mkNixosConfig;

      homeConfigurations =
        let
          defaultHomeConfig.home = rec {
            username = "douglas";
            stateVersion = "22.05";
            homeDirectory = "/home/${username}";
          };
          extraArgs = {
            devShells = devShells;
            nix-colors = inputs.nix-colors;
          };

        in mapModules allModules.home-configs (mkHomeConfig defaultHomeConfig systemPackages extraArgs);

      # callPackage imports the package and then calls it
      # packages = mergePackages (fundModules ./packages)
      # mergePackages takes a list of attributes sets, where each set is a mapping of supported systems to a single package
      #builtins.listToAttrs (findModules ./packages);packages.x86_64-linux = builtins.listToAttrs (findModules ./packages);
      packages = eachSystem (system:
        mapModules allModules.packages (p: systemPackages.${system}.callPackage p {}));
    };
}
