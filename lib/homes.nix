{ inputs, lib, mylib, ... }:

with lib;
with mylib;
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
        inherit inputs system mylib;
      };
    };

  mapHomes = dir: attrs @ { system ? system, ... }:
    mapModules dir
      (homePath: mkHome homePath attrs);
}
