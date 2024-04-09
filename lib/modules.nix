{ lib, ... }:

let
  inherit (builtins) attrValues baseNameOf concatLists listToAttrs mapAttrs pathExists readDir;
  inherit (lib) hasSuffix mapAttrs' nameValuePair removeSuffix;
in
rec {
  # Function to recursively collect modules from a directory and squish them all
  # together into a top-level namespace. A directory containing a "default.nix"
  # file will not be recursed into, as it will be considered a top-level module.
  findModules = dir:
    concatLists (attrValues (mapAttrs
      (name : type:
        if type == "regular" &&
          hasSuffix ".nix" name && name != "default.nix" then [{
            name = removeSuffix ".nix" name;
            value = dir + "/${name}";
        }] else if type == "directory" &&
            pathExists "${toString dir}/${name}/default.nix" then [{
            inherit name;
            value = dir + "/${name}";
        }] else if type == "directory" then
            findModules (dir + "/${name}")
        else []) (readDir dir)));

  # Given a list of paths, return an attrset of path name to attrset of modules
  loadModules = (paths:
    listToAttrs (
      map
        (path: nameValuePair (baseNameOf path) (listToAttrs (findModules path)))
        paths
    )
  );

  # For a given attrset mapping names to module paths, run the supplied function
  # on each module.
  mapModules = modules: fn:
    mapAttrs' (name: value: nameValuePair name (fn value)) modules;
}
