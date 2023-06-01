{
  description = "dmayle's nix system configurations, both nixos and home-manager";

  # This is a collection of sources to have their versions and hashes managed
  # by this flake
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixgl = {
      url = "github:guibou/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
  outputs = inputs @ { self, nixpkgs, home-manager, nixgl, ... }:
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

      injectPackages = mapModules ./packages (p: systemPackages.x86_64-linux.callPackage p {});

      pkgsFor = configurePackagesFor inputs.nixpkgs {
        android_sdk.accept_license = true;
        allowUnfree = true;
      } [
        nixgl.overlay
        (final: prev: {inherit (injectPackages) joycond_cemuhook prusa-slicer-alpha yuzu-ea; }) #yuzu-ea;})
        (final: prev: {
          ryujinx = prev.ryujinx.overrideAttrs (old: let oldConfigureHook = (builtins.head (builtins.filter (p: p.name == "dotnet-configure-hook") old.nativeBuildInputs)); in rec {
            pname = "ryujinx";
            version = "1.1.810";
            src = prev.fetchFromGitHub {
              owner = "Ryujinx";
              repo = "Ryujinx";
              sha256 = "sha256-Gi8Qk/XiDeD9lOr8SRT+xuM0JeJ+2EEtwqmsukn0B+o=";
              rev = "${version}";
            };
            testProjectFile = "src/" + old.testProjectFile; # Source was moved inside of src/ subdirectory
            nugetDeps = prev.mkNugetDeps {
              name = "${pname}-${version}";
              nugetDeps = (args:
              (builtins.filter (p:
                  p.name != "System.IdentityModel.Tokens.Jwt.6.29.0.nupkg"
                  && p.name != "Microsoft.IdentityModel.JsonWebTokens.6.29.0.nupkg"
                  && p.name != "Microsoft.IdentityModel.Tokens.6.29.0.nupkg"
                  && p.name != "Microsoft.IdentityModel.Logging.6.29.0.nupkg"
                  && p.name != "Microsoft.IdentityModel.Abstractions.6.29.0.nupkg"
                ) (import old.nugetDeps args))
              ++ [
                  (args.fetchNuGet { pname = "Microsoft.IdentityModel.JsonWebTokens"; version = "6.30.1"; sha256 = "sha256-m0q6wyQX2erKahaq3NtLAdrZ2Mk+AHlz2zfTny3QMLA="; })
                  (args.fetchNuGet { pname = "Microsoft.IdentityModel.Tokens"; version = "6.30.1"; sha256 = "sha256-war/sY+itGgV1cLryaA/ct5BUbNCcu0pLZcfan3YA4k="; })
                  (args.fetchNuGet { pname = "Microsoft.IdentityModel.Logging"; version = "6.30.1"; sha256 = "sha256-+jtOwuYMKiy3jGp08pH1BC1U7H4O3Q+3V04LhgGsswk="; })
                  (args.fetchNuGet { pname = "Microsoft.IdentityModel.Abstractions"; version = "6.30.1"; sha256 = "sha256-4UZ4RDhTC+LMS+taMtYBZOG/BZG+Xqc26T8QNo/6Z8k="; })
                  (args.fetchNuGet { pname = "System.IdentityModel.Tokens.Jwt"; version = "6.30.1"; sha256 = "sha256-gt222dwY9IPCOyyFsJIeyLP527eAQkYLInNenrgunbg="; })
                  (args.fetchNuGet { pname = "DynamicData"; version = "7.13.8"; sha256 = "sha256-pBh8mIeCUNs3Dm7LQrQKYYea1F0+p7b0m4YAVOZf3IM="; })
                ]
              );
            };
            dotnet-sdk = prev.dotnetCorePackages.sdk_7_0;
            sdkDeps = prev.lib.lists.flatten [ dotnet-sdk.packages ];
            sdkSource = prev.mkNugetSource {
              name = "dotnet-sdk-${dotnet-sdk.version}-source";
              deps = sdkDeps;
            };
            dependenciesSource = prev.mkNugetSource {
              name = "${pname}-${version}-dependencies-source";
              description = "A Nuget source with the dependencies for ${pname}-${version}";
              deps = [ nugetDeps ];
            };
            nuget-source = prev.symlinkJoin {
              name = "${pname}-${version}-nuget-source";
              paths = [ dependenciesSource sdkSource ];
            };
            nativeBuildInputs = (builtins.filter (p: p.name != "dotnet-configure-hook") old.nativeBuildInputs) ++ [
              (oldConfigureHook.overrideAttrs (old: {
                nugetSource = nuget-source;
              }))
            ];
          });
        })
        # (final: prev: { prusa-slicer = prev.prusa-slicer.overrideAttrs (old: rec {
        #   version = "2.6.0-alpha5";
        #   patches = [];
        #   buildInputs = old.buildInputs ++ [ prev.pkgs.qhull ];
        #   src = prev.fetchFromGitHub {
        #     owner = "prusa3d";
        #     repo = "PrusaSlicer";
        #     sha256 = "sha256-sIbwuB1Ai2HrzN7tYm6gDL4aCppRcgjsdkuqQTTD3d0=";
        #     rev = "version_${version}";
        #   };
        # });})
      ];

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
      # flakeSystems is a function that takes a list of shells and makes them available for each supported system
      # devShells = flakeSystems (findModules ./dev-shells);
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

      # packages = mergePackages (fundModules ./packages)
      # mergePackages takes a list of attributes sets, where each set is a mapping of supported systems to a single package
      #builtins.listToAttrs (findModules ./packages);packages.x86_64-linux = builtins.listToAttrs (findModules ./packages);
      packages.x86_64-linux = mapModules ./packages (p: systemPackages.x86_64-linux.callPackage p {});
    };
}
