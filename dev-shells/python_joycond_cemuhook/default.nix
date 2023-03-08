{ pkgs ? import <nixpkgs> {} }:
let
  pyAppEnv = pkgs.poetry2nix.mkPoetryEnv {
    projectDir = ./.;
    editablePackageSources = {
      my-app = ./src;
    };
  };
in pyAppEnv.env
