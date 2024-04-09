{ lib, ... }:

let
  inherit (builtins) attrValues baseNameOf concatLists listToAttrs readDir pathExists;
  inherit (lib) id mapAttrsToList filterAttrs hasPrefix hasSuffix mapAttrs' nameValuePair removeSuffix;
in
rec {
  # Convert a string object to a path object
  asPath = str: ./. + str;

  # Function to recursively collect modules from a directory and squish them all
  # together into a top-level namespace.
  # A directory containing a "default.nix" file will not be recursed into, and
  # may contain non-nix files.
  # Any directory containing sub-modules may not contain non-nix files.
  findModules = dir:
    concatLists (attrValues (builtins.mapAttrs
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

  configurePackagesForSystem = pkgs: config: overlays: system:
    import pkgs {
      localSystem = { inherit system; };
      inherit config overlays;
    };

  # Given a list of paths, return an attrset of path name to attrset of modules
  loadModules = (paths:
    listToAttrs (
      map
        (path: nameValuePair (baseNameOf path) (listToAttrs (findModules path)))
        paths
    )
  );

  # Read out a system file from the given path and return the contents
  systemForConfig = path: lib.removeSuffix "\n" (builtins.readFile (path + "/system"));

  eachNixConfig = fn: configs:
  mapModules configs (config:
  if pathExists "${toString config}/system" then
  fn config
  else config);

  # For a given directory, return a set of key, value pairs where each key is
  # either the name of a nix file in that directory, or a sub-directory with
  # a 'default.nix' file inside of it, excluding 'default.nix' in the given
  # directory, and the value is the result of calling the function with the
  # full path of the file or directory.
  mapModules = foundModules: fn:
    mapAttrs'
      (name: value: nameValuePair name (fn value))
      foundModules;
}
