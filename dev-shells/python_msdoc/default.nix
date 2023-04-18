{ pkgs ? import <nixpkgs> {} }:
let
  my-packages = p: with p; [
    python-docx
  ];
  my-python = pkgs.python3.withPackages my-packages;
in my-python.env
