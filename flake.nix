{
  description = "dmayle's nix system configurations, both nixos and home-manager";

  # This is a collection of sources to have their versions and hashes managed
  # by this flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    };
    nixpkgs-lib = {
      url = "github:nix-community/nixpkgs.lib";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-eval-jobs.follows = "nix-eval-jobs";
      inputs.lib-aggregate.follows = "lib-aggregate";
    };
    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    vim-maximizer = {
      url = "github:szw/vim-maximizer";
      flake = false;
    };
    nvim-colorizer = {
      url = "github:norcalli/nvim-colorizer.lua";
      flake = false;
    };
    indent-blankline = {
      url = "github:lukas-reineke/indent-blankline.nvim";
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
    conflict-marker = {
      url = "github:rhysd/conflict-marker.vim";
      flake = false;
    };
  };

  # The output of this is my nixos configurations and home manager configurations
  outputs = inputs @ { self, nixpkgs, home-manager, nixgl, ... }:
    # I need to setup three things in order for the code contained in this
    # flake to work properly:
    # 1) Import and setup library code which is used by my modules, but also by
    #    this flake to easily setup multiple configurations
    # 2) Import and setup code to be made available by my modules: packages,
    #    overlays, and mixins shared by different configurations
    # 3) Setup nixpkgs to enable unfree modules
    let
      inherit (flib) findModules configurePackagesForSystem mapModules mapModules' mkHomeConfig systemForConfig;

      lib = nixpkgs.lib;

      flib = import ./lib { inherit inputs lib; };

      # This creates an x86_64-linux based package tree for the packages in this flake :-(
      injectPackages = mapModules ./packages (p: systemPackages.x86_64-linux.callPackage p {});

      # Global nixpkgs config used in this flake
      pkgConfig = {
        android_sdk.accept_license = true;
        allowUnfree = true;
        cudaSupport = true;
      };

      # Global nixpkgs overlays used in this flake, depends on x86_64-linux packages
      pkgOverlays = [
        inputs.nixpkgs-wayland.overlay
        (final: prev: {inherit (injectPackages) joycond_cemuhook; })
      ];

      # Curry new config and overlays into nixpkgs as per-system function
      pkgsForSystem = configurePackagesForSystem nixpkgs pkgConfig pkgOverlays;

      # Generate a list systems supported by the nixos and home-manager configs
      supportedSystems = lib.unique (mapModules' ./home-configs systemForConfig ++ mapModules' ./nixos-configs systemForConfig);

      # Create an attrset of systems to nixpkgs for that system
      systemPackages = lib.genAttrs supportedSystems pkgsForSystem;
    in

    rec {
      #devShells.x86_64-linux = builtins.listToAttrs (findModules ./dev-shells);
      # flakeSystems is a function that takes a list of shells and makes them available for each supported system
      # devShells = flakeSystems (findModules ./dev-shells);
      devShells = lib.genAttrs supportedSystems (system:
        let
          shells = builtins.attrNames (builtins.readDir ./dev-shells);
          myFunc = name:
            import (./dev-shells + "/${name}") { pkgs = systemPackages.${system}; };
        in lib.genAttrs shells myFunc
      );

      homeManagerModules = builtins.listToAttrs (findModules ./home-modules);

      homeManagerProfiles = builtins.listToAttrs (findModules ./home-profiles);

      homeManagerRoles = import ./home-roles;

      nixosModules = builtins.listToAttrs (findModules ./nixos-modules);

      nixosProfiles = builtins.listToAttrs (findModules ./nixos-profiles);

      nixosRoles = import ./nixos-roles;

      nixosConfigurations = with lib;
        let
          configs = builtins.attrNames (builtins.readDir ./nixos-configs);

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
              specialArgs = { inherit inputs; };
            };
        in lib.genAttrs configs mkNixosConfig;

      homeConfigurations = with home-manager.lib;
        let
          defaultHomeConfig.home = rec {
            username = "douglas";
            stateVersion = "22.05";
            homeDirectory = "/home/${username}";
          };
          extraArgs = {
            devShells = devShells;
          };

        in mapModules ./home-configs (mkHomeConfig defaultHomeConfig systemPackages extraArgs);

      # packages = mergePackages (fundModules ./packages)
      # mergePackages takes a list of attributes sets, where each set is a mapping of supported systems to a single package
      #builtins.listToAttrs (findModules ./packages);packages.x86_64-linux = builtins.listToAttrs (findModules ./packages);
      packages.x86_64-linux = mapModules ./packages (p: systemPackages.x86_64-linux.callPackage p {});
    };
}
