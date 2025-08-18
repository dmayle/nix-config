{
  description = "dmayle's nix system configurations, both nixos and home-manager";

  # This is a collection of sources to have their versions and hashes managed
  # by this flake.
  inputs = {
    # ##########################################################################
    # Core Flake Inputs (nixpkgs, systems, home-manager)
    # ##########################################################################
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ##########################################################################
    # NixGL: Fixup OpenGL of nix programs on non-NixOS systems
    # ##########################################################################
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # ##########################################################################
    # Hyperland and Hy3 (tiled WM)
    # ##########################################################################
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/hyprland";
      ref = "refs/tags/v0.50.1";
      submodules = true;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    hy3 = {
      type = "git";
      url = "https://github.com/outfoxxed/hy3";
      ref = "refs/tags/hl0.50.0";
      inputs.hyprland.follows = "hyprland";
    };
    # ##########################################################################
    # Sops-Nix (declarative secret management)
    # ##########################################################################
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ##########################################################################
    # Disko (declarative disk configurations)
    # ##########################################################################
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ##########################################################################
    # Nix Colors (theming support)
    # ##########################################################################
    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    # ##########################################################################
    # Stylix (theming support)
    # ##########################################################################
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ##########################################################################
    # Nixified AI (AI Tools like ComfyUI)
    # ##########################################################################
    nixified-ai = {
      url = "github:nixified-ai/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ##########################################################################
    # Neovim inputs (unpackaged plugins and spelling dictionaries)
    # ##########################################################################
    vim-fakeclip = {
      url = "github:kana/vim-fakeclip";
      flake = false;
    };
    NeoSolarized-nvim = {
      url = "github:Tsuzat/NeoSolarized.nvim";
      flake = false;
    };
    mcp-hub = {
      url = "github:ravitemer/mcp-hub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcphub-nvim = {
      url = "github:ravitemer/mcphub.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fine-cmdline-nvim = {
      url = "github:VonHeikemen/fine-cmdline.nvim";
      flake = false;
    };
    nvim-spell-en-utf8-dictionary = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/en.utf-8.spl";
      flake = false;
    };
    nvim-spell-en-utf8-suggestions = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/en.utf-8.sug";
      flake = false;
    };
    nvim-spell-en-ascii-dictionary = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/en.ascii.spl";
      flake = false;
    };
    nvim-spell-en-ascii-suggestions = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/en.ascii.sug";
      flake = false;
    };
    nvim-spell-en-latin1-dictionary = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/en.latin1.spl";
      flake = false;
    };
    nvim-spell-en-latin1-suggestions = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/en.latin1.sug";
      flake = false;
    };
    nvim-spell-fr-utf8-dictionary = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/fr.utf-8.spl";
      flake = false;
    };
    nvim-spell-fr-utf8-suggestions = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/fr.utf-8.sug";
      flake = false;
    };
    nvim-spell-fr-latin1-dictionary = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/fr.latin1.spl";
      flake = false;
    };
    nvim-spell-fr-latin1-suggestions = {
      url = "file+https://ftp.nluug.nl/vim/runtime/spell/fr.latin1.sug";
      flake = false;
    };
    # ##########################################################################
    # Transient dependencies (input dependencies that I want to use my inputs)
    # ##########################################################################
    nixpkgs-lib = {
      url = "github:nix-community/nixpkgs.lib";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nix-eval-jobs = {
      url = "github:nix-community/nix-eval-jobs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lib-aggregate = {
      url = "github:nix-community/lib-aggregate";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
  };

  # This flake outputs custom packages, development shells, overlays, and
  # configurations for Home Manager and NixOS that take advantage of them.
  outputs =
    inputs@{
      self,
      systems,
      nixpkgs,
      ...
    }:
    let
      inherit (builtins) mapAttrs;
      inherit (flib)
        loadModules
        mkPackages
        mkHomeConfig
        mkNixosConfig
        ;

      lib = nixpkgs.lib;

      flib = import ./lib { inherit inputs lib; };

      # Use nix-systems to configure supported systems.
      eachSystem = lib.genAttrs (import systems);

      # Load all modules only once.
      modules = loadModules [
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

      # Global nixpkgs overlays used in this flake.
      overlays = [
        # Make flake packages available to all configs
        (final: prev: packages)
      ];

      # Create an attrset of systems to nixpkgs for each system using config.
      systemPackages = eachSystem (system: mkPackages nixpkgs pkgConfig overlays system);

      # Load all of the packages from this flake so they can also be used in the
      # packages overlays.
      packages = eachSystem (
        system: mapAttrs (name: p: systemPackages.${system}.callPackage p { }) modules.packages
      );

      # Load all of the devShells from this flake so they can also be used in
      # the module args.
      devShells = eachSystem (
        system: mapAttrs (name: p: import p { pkgs = systemPackages.${system}; }) modules.dev-shells
      );

      # Args passed to all modules used for configurations.
      extraArgs = { inherit inputs devShells; };
    in

    {
      inherit devShells packages overlays;

      homeManagerProfiles = modules.home-profiles;

      homeManagerRoles = modules.home-roles;

      homeConfigurations = mapAttrs (mkHomeConfig systemPackages extraArgs) modules.home-configs;

      nixosProfiles = modules.nixos-profiles;

      nixosRoles = modules.nixos-roles;

      nixosConfigurations = mapAttrs (mkNixosConfig systemPackages extraArgs) modules.nixos-configs;
    };
}
