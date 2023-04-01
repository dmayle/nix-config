{ pkgs ? import <nixpkgs> {} }:
let
  pythonEnv = pkgs.poetry2nix.mkPoetryEnv {
    projectDir = ./.;
  };
in pkgs.mkShell rec {
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath packages;
  buildInputs = [
    pkgs.poetry
    pythonEnv
  ];
  packages = with pkgs; [
    poetry
    pkg-config
  ];
}
