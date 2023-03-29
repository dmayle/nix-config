{ pkgs ? import <nixpkgs> {} }:
let
  my-packages = p: with p; [
    tensorflowWithCuda
    keras
    matplotlib
    tkinter
  ];
  my-python = pkgs.python3.withPackages my-packages;
in my-python.env
