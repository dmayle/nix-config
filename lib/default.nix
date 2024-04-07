{ inputs, lib, ... }:

let
  # Load mapModules from ./modules.nix manually; use it to load all of flib.
  mapModules = (import ./modules.nix {
    inherit lib;
    flib.attrs = import ./attrs.nix { inherit lib; };
  }).mapModules;

  # Load the modules in this directory, using mapModules
  flib = lib.makeExtensible (self:
    mapModules ./. (f: import f { inherit inputs lib; flib = self; }));
in
# Take the existing flib attribute set, which is roughly a map of submodule
# names to submodules (such that flib.attrs contains the module code from
# attrs.nix), and promote all of the submodule properties so that
# they're directly available on flib
flib.extend
  (self: super:
    lib.foldr (a: b: a // b) { } (lib.attrValues super))
