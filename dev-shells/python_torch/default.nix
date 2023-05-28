{ pkgs ? import <nixpkgs> {} }:
let
  my-packages = p: with p; [
    torchWithCuda
    matplotlib
    jupyter
    graphviz
    scikit-learn
  ];
  my-python = pkgs.python3.withPackages my-packages;
in my-python.env
