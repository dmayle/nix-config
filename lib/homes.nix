{ inputs, lib, flib, ... }:

with lib;
with flib;
let sys = "x86_64-linux";
in
{
  mkHome = pkgs: path: attrs @ { system ? sys, ... }:
    let
      username = removeSuffix ".nix" (baseNameOf path);
      homeDirectory = "/home/${username}";
      defaults = { config, lib, ... }: {
        programs.home-manager.enable = true;
        xdg.enable = true;
        xdg.mime.enable = true;
        targets.genericLinux.enable = true;
        home.stateVersion = "22.05";
        home.username = username;
        home.homeDirectory = homeDirectory;
      };
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = (mapModulesRec' (toString ../modules/home) import) ++ [
        defaults
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)
        (import path)
      ];
      extraSpecialArgs = {
        inherit inputs system flib;
      };
    };

  mkHomeConfig = defaults: systemPackages: path:
    let
      system = lib.removeSuffix "\n" (builtins.readFile (path + "/system"));
    in inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = systemPackages.${system};
      modules = [
        { _module.args = { inherit flib; }; }
        (import (path))
        defaults
      ];
      # Only used for importable arguments
      extraSpecialArgs = { inherit inputs; };
    };

  mapHomes = dir: attrs @ { system ? system, ... }:
    mapModules dir
      (homePath: mkHome homePath attrs);
}
