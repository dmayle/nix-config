{ inputs, lib, pkgs, ... }:

let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  # Load the 'modules' module in order to get access to mapModules, it depends on attrs
  modules = import ./modules.nix {
    inherit lib;
    self.attrs = import ./attrs.nix { inherit lib; self = { }; };
  };

  # Load the modules in this directory, using mapModules
  mylib = makeExtensible (self:
    with self; mapModules ./.
      (file: import file { inherit self lib pkgs inputs; mylib = self; }));
in
# Take the existing mylib attribute set, which is roughly a map of submodule
# names to submodules (such that mylib.attrs contains the module code from
# attrs.nix), and promote all of the submodule properties so that
# they're directly available on mylib
mylib.extend
  (self: super:
    foldr (a: b: a // b) { } (attrValues super))
