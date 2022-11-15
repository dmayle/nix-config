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
      inherit (flib) findModules configurePackagesFor mapModules mkHomeConfig;

      flib = import ./lib { inherit inputs; lib = nixpkgs.lib; };

      pkgsFor = configurePackagesFor inputs.nixpkgs {
        android_sdk.accept_license = true;
        allowUnfree = true;
      };

      systemPackages =
        let
          system_types =
            let
              fn = path: nixpkgs.lib.removeSuffix "\n" (builtins.readFile (path + "/system"));
            in
              nixpkgs.lib.unique (builtins.attrValues (mapModules ./home-configs fn) ++ builtins.attrValues (mapModules ./nixos-configs fn));
        in nixpkgs.lib.genAttrs system_types (system: pkgsFor system);
    in

    {
      #devShells.x86_64-linux = builtins.listToAttrs (findModules ./dev-shells);
      devShells.x86_64-linux = with nixpkgs.lib;
        let
          shells = builtins.attrNames (builtins.readDir ./dev-shells);
          myFunc = name:
            import (./dev-shells + "/${name}") { pkgs = systemPackages.x86_64-linux; };
        in nixpkgs.lib.genAttrs shells myFunc;

      homeManagerModules = builtins.listToAttrs (findModules ./home-modules);

      homeManagerProfiles = builtins.listToAttrs (findModules ./home-profiles);

      homeManagerRoles = import ./home-roles;

      nixosModules = builtins.listToAttrs (findModules ./nixos-modules);

      nixosProfiles = builtins.listToAttrs (findModules ./nixos-profiles);

      nixosRoles = import ./nixos-roles;

      nixosConfigurations = with nixpkgs.lib;
        let
          configs = builtins.attrNames (builtins.readDir ./nixos-configs);

          mkNixosConfig = name:
            let
              system = nixpkgs.lib.removeSuffix "\n" (builtins.readFile (./nixos-configs + "/${name}/system"));
              pkgs = systemPackages.${system};
            in nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                (import (./nixos-configs + "/${name}"))
                { _module.args = { inherit flib; }; }
                { nixpkgs.pkgs = pkgs; }
              ];
              # Only used for importable arguments
              specialArgs = { inherit inputs; };
            };
        in nixpkgs.lib.genAttrs configs mkNixosConfig;

      homeConfigurations = with home-manager.lib;
        let
          defaultHomeConfig.home = rec {
            username = "douglas";
            stateVersion = "22.05";
            homeDirectory = "/home/${username}";
          };

        in mapModules ./home-configs (mkHomeConfig defaultHomeConfig systemPackages);
    };
}
