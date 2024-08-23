{ pkgs ? import <nixpkgs> {} }:
let
  my-packages = p: with p; [
    torchWithCuda
    #matplotlib
    #graphviz
    #scikit-learn
    #sqlalchemy
    ipykernel # Allow use as jupyter kernel
  ];
  my-python = pkgs.python3.withPackages my-packages;
in my-python.env
