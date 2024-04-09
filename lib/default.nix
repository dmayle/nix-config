{ inputs, lib, ... }:

let
  # Load libModules from ./modules.nix manually; use it to load all of flib.
  modules = (import ./modules.nix { inherit lib; });

  subModules = (modules.loadModules [ ./. ]).lib;

  # Load the modules in this directory
  flib = lib.makeExtensible (self:
    modules.mapModules subModules (f: import f { inherit inputs lib; flib = self; }));
in
# Take the existing flib attribute set, which is roughly a map of submodule
# names to submodules (such that flib.attrs contains the module code from
# attrs.nix), and promote all of the submodule properties so that
# they're directly available on flib
flib.extend
  (self: super:
    lib.foldr (a: b: a // b) { } (lib.attrValues super))
