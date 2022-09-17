{
  description = "dmayle's nix system configurations, both nixos and home-manager";

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

  outputs = inputs @ { self, nixpkgs, ... }:
    let
      inherit (mylib) mapModules mapModulesRec mapHosts mapHomes;

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

      system = "x86_64-linux";

      mkPkgs = pkgs: overlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = overlays;
      };
      pkgs = mkPkgs nixpkgs (lib.attrValues self.overlays);

      lib = nixpkgs.lib;
      mylib = import ./lib { inherit pkgs inputs lib; };

      overlay = final: prev: {
        my = self.packages."${system}";
      } // (import ./overlays { inherit inputs; }) final prev;
    in

    {
      overlays = {};

      packages."${system}" = mapModules ./packages (p: pkgs.callPackage p { inherit inputs; });

      mixins = builtins.listToAttrs (findModules ./mixins);

      nixosConfigurations = mapHosts ./hosts { };

      homeConfigurations = mapHomes ./homeconfigs { };
    };
}
