{
  description = "dmayle's nix system configurations, both nixos and home-manager";

  # This is a collection of sources to have their versions and hashes managed
  # by this flake
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nixgl.url = "github:guibou/nixGL";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
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
  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    # I need to setup three things in order for the code contained in this
    # flake to work properly:
    # 1) Import and setup library code which is used by my modules, but also by
    #    this flake to easily setup multiple configurations
    # 2) Import and setup code to be made available by my modules: packages,
    #    overlays, and mixins shared by different configurations
    # 3) Setup nixpkgs to enable unfree modules
    let
      #inherit (mylib) mapModules mapModulesRec mapHosts mapHomes;

      #mylib = import ./lib { inherit pkgs inputs; lib = nixpkgs.lib; };

      # Function to recursively collect modules from directory (Refactor this)
      findModules = dir:
        builtins.concatLists (builtins.attrValues (builtins.mapAttrs
          (name : type:
            if type == "regular" then [{
              name = builtins.elemAt (builtins.match "(.*)\\.nix" name) 0;
              value = dir + "/${name}";
            }] else if (builtins.readDir (dir + "/${name}"))
            ? "default.nix" then [{
              inherit name;
              value = dir + "/${name}";
            }] else
              findModules (dir + "/${name}")) (builtins.readDir dir)));

      pkgsFor = system:
        import inputs.nixpkgs {
          #overlays = [ self.overlay ];
          localSystem = { inherit system; };
          config = {
            android_sdk.accept_license = true;
          };
        };
      system = "x86_64-linux";

      mkPkgs = pkgs: overlays: import pkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      pkgs = mkPkgs nixpkgs (nixpkgs.lib.attrValues self.overlays);


      #overlay = final: prev: {
        #my = self.packages."${system}";
      #} // (import ./overlays { inherit inputs; }) final prev;
    in

    {
      homeManagerModules = builtins.listToAttrs (findModules ./home-modules);

      homeManagerProfiles = builtins.listToAttrs (findModules ./home-profiles);

      homeManagerRoles = import ./home-roles;

      nixosModules = builtins.listToAttrs (findModules ./nixos-modules);

      nixosProfiles = builtins.listToAttrs (findModules ./nixos-profiles);

      nixosRoles = import ./nixos-roles;

      #overlay = {};
      overlays = {};

      #packages."${system}" = mapModules ./packages (p: pkgs.callPackage p { inherit inputs; });

      nixosConfigurations = with nixpkgs.lib;
        let
          configs = builtins.attrNames (builtins.readDir ./nixos-configs);

          mkHost = name:
            let
              system = builtins.readFile (./nixos-configs + "/${name}/system");
              pkgs = pkgsFor system;
            in nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                (import (./nixos-configs + "/${name}"))
                { nixpkgs.pkgs = pkgs; }
                { device = name; }
              ];
              # TODO: migrate from specialArgs to _module.args
              specialArgs = { inherit inputs; };
            };
        in genAttrs configs mkHost;

      legacyPackages.x86_64-linux = pkgsFor "x86_64-linux";

      homeConfigurations = with home-manager.lib;
        let
          configs = builtins.attrNames (builtins.readDir ./home-configs);

          mkHost = name:
            let
              username = builtins.readFile (./home-configs + "/${name}/username");
              system = builtins.readFile (./home-configs + "/${name}/system");
            in homeManagerConfiguration {
              inherit pkgs;
              modules = [
                (import (./home-configs + "/${name}"))
                { home = { inherit username; stateVersion = "22.05"; homeDirectory = "/home/douglas"; }; }
              ];
              extraSpecialArgs = { inherit inputs; };
            };
        in nixpkgs.lib.genAttrs configs mkHost;

      #homeConfigurations = mapHomes ./homeconfigs { };
    };
}
