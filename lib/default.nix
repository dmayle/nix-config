{ inputs, lib, ... }:

let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  # Load the 'modules' module in order to get access to mapModules, it depends on attrs
  modules = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix { inherit lib; self = { }; };
  };

  # Load the modules in this directory, using mapModules
  flib = makeExtensible (self:
    with self; mapModules ./.
      (file: import file { inherit self lib inputs; flib = self; }));
in
# Take the existing flib attribute set, which is roughly a map of submodule
# names to submodules (such that flib.attrs contains the module code from
# attrs.nix), and promote all of the submodule properties so that
# they're directly available on flib
flib.extend
  (self: super:
    foldr (a: b: a // b) { } (attrValues super))
