{ pkgs ? import <nixpkgs> {} }:
let
  my-packages = p: with p; [
    python-docx
    libxml2
    pkgs.libxml2
    pkgs.libxml2Python
    lxml
    ipykernel # Allow use as jupyter kernel
  ];
  my-python = pkgs.python3.withPackages my-packages;
in my-python.env
