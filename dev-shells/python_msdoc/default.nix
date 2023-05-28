{ pkgs ? import <nixpkgs> {} }:
let
  my-packages = p: with p; [
    python-docx
    libxml2
    pkgs.libxml2
    pkgs.libxml2Python
    lxml
    jupyter
  ];
  my-python = pkgs.python3.withPackages my-packages;
in my-python.env
