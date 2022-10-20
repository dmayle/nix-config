{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "go_bazel";
  targetPkgs = pkgs: [
    pkgs.bazel
    pkgs.glibc
    pkgs.gcc
  ];
}).env
