{ pkgs ? import <nixpkgs> {} }:
let
  pyAppEnv = pkgs.poetry2nix.mkPoetryApplication {
    projectDir = ./.;
  };
in pyAppEnv.env
