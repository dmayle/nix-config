{
  description = "dmayle's nix system configurations, both nixos and home-manager";

  # This is a collection of sources to have their versions and hashes managed
  # by this flake.
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
    let
      inherit (flib) configurePackagesForSystem mapModules mkHomeConfig
        mkNixosConfig;

      lib = nixpkgs.lib;

      flib = import ./lib { inherit inputs lib; };

      eachSystem = lib.genAttrs (import systems);

      # Load all modules only once.
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

      # Global nixpkgs config used in this flake.
      pkgConfig = {
        android_sdk.accept_license = true;
        allowUnfree = true;
        cudaSupport = true;
      };

      # Global nixpkgs overlays used in this flake, depends on x86_64-linux
      # packages.
      pkgOverlays = [
        (final: prev: packages)
      ];

      # Create an attrset of systems to nixpkgs for each system using config.
      systemPackages = eachSystem (system:
        configurePackagesForSystem nixpkgs pkgConfig pkgOverlays system);

      # Load all of the packages from this flake so they can also be used in the
      # packages overlays.
      packages = eachSystem (system:
        mapModules allModules.packages (p: systemPackages.${system}.callPackage p {}));

      # Load all of the devShells from this flake so they can also be used in
      # the module args.
      devShells = eachSystem (system:
        mapModules allModules.dev-shells (p: import p { pkgs = systemPackages.${system}; }));

      # Args passed to all modules used for configurations.
      extraArgs = { inherit inputs devShells; };
    in

    {
      inherit devShells packages;

      homeManagerModules = allModules.home-modules;

      homeManagerProfiles = allModules.home-profiles;

      homeManagerRoles = allModules.home-roles;

      homeConfigurations = mapModules allModules.home-configs (
        mkHomeConfig systemPackages extraArgs);

      nixosModules = allModules.nixos-modules;

      nixosProfiles = allModules.nixos-profiles;

      nixosRoles = allModules.nixos-roles;

      nixosConfigurations = mapModules allModules.nixos-configs (
        mkNixosConfig systemPackages extraArgs);
    };
}
