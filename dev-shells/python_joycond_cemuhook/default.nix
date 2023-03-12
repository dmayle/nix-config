{ pkgs ? import <nixpkgs> {} }:
let
  pyAppEnv = pkgs.poetry2nix.mkPoetryEnv {
    projectDir = ./.;
    editablePackageSources = {
      my-app = ./src;
    };
  };
in
  pkgs.mkShell {
    buildInputs = with pkgs; [ python39 poetry python39Packages.dbus-python python39Packages.evdev python39Packages.pyudev python39Packages.termcolor ];
  }
#in pyAppEnv.env
