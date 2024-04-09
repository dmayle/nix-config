{ lib, flib, ... }:

let
  inherit (builtins) attrValues baseNameOf concatLists listToAttrs readDir pathExists;
  inherit (lib) id mapAttrsToList filterAttrs hasPrefix hasSuffix nameValuePair removeSuffix;
  inherit (flib.attrs) mapFilterAttrs;
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
        if type == "regular" then [{
          name = removeSuffix ".nix" name;
          value = dir + "/${name}";
        }] else if (readDir (dir + "/${name}"))
        ? "default.nix" then [{
          inherit name;
          value = dir + "/${name}";
        }] else
          findModules (dir + "/${name}")) (readDir dir)));

  # readDir generates { "one.nix" = "regular"; "subdir" = "directory" } for each
  # directory entry
  # mapAttrs calls this function that turns that into { "one.nix" = [{ name
  # = "one"; value = ./rootdir/one.nix }], "subdir" = [{ name = "subdir"; value
  # = ./rootdir/subdir }]}
  # attrValues discards the original keys and generates list of lists:
  # [[{ name = "one"; value = ./rootdir/one.nix }] [{ name = "subdir", value
  # = ./rootdir/subdir }]]
  # concatLists makes it a single list

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

  # For a given directory, return a set of key, value pairs where each key is
  # either the name of a nix file in that directory, or a sub-directory with
  # a 'default.nix' file inside of it, excluding 'default.nix' in the given
  # directory, and the value is the result of calling the function with the
  # full path of the file or directory.
  mapModules = dir: fn:
    mapFilterAttrs
      (n: v:
        v != null &&
        !(hasPrefix "_" n))
      (n: v:
        let path = "${toString dir}/${n}"; in
        if v == "directory" && pathExists "${path}/default.nix"
        then nameValuePair n (fn path)
        else if v == "regular" &&
          n != "default.nix" &&
          hasSuffix ".nix" n
        then nameValuePair (removeSuffix ".nix" n) (fn path)
        else nameValuePair "" null)
      (readDir dir);

  # Return a list where each value is the result of calling the function with
  # either the path to a nix file in the given directory, or a sub-directory
  # containing 'default.nix', but excluding the file 'default.nix' if it exists
  # in the given directory
  mapModules' = dir: fn:
    attrValues (mapModules dir fn);

  # Return a nested set where each key is the name of either a file or
  # a directory. If the key is a filename, then the value is the result of
  # calling the function with the path to that file.  If it's a directory, then
  # the value is the same kind of set, with one entry for each file or
  # sub-directory, recursively.
  mapModulesRec = dir: fn:
    mapFilterAttrs
      (n: v:
        v != null &&
        !(hasPrefix "_" n))
      (n: v:
        let path = "${toString dir}/${n}"; in
        if v == "directory"
        then nameValuePair n (mapModulesRec path fn)
        else if v == "regular" && n != "default.nix" && hasSuffix ".nix" n
        then nameValuePair (removeSuffix ".nix" n) (fn path)
        else nameValuePair "" null)
      (readDir dir);

  # Return a list where each element is the result of calling the supplied
  # function on the path of a nix file contained either in this directory, or
  # in a subdirectory.  It ignores a file called 'default.nix' in the given
  # directory, but will handle 'default.nix' in any subdirectories.
  mapModulesRec' = dir: fn:
    let
      dirs =
        mapAttrsToList
          (k: _: "${dir}/${k}")
          (filterAttrs
            (n: v: v == "directory" && !(hasPrefix "_" n))
            (readDir dir));
      files = attrValues (mapModules dir id);
      paths = files ++ concatLists (map (d: mapModulesRec' d id) dirs);
    in
    map fn paths;
}
