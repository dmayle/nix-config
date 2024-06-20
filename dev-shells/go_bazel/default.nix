{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "go_bazel";
  targetPkgs = pkgs: with pkgs; [
    bazel
    glibc
    gcc
    go
    jdk11
  ];
}).env
