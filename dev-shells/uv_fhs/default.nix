{ pkgs ? import <nixpkgs> {} }:
let
  my-env = pkgs.buildFHSUserEnv {
    name = "uv-fhs";
    targetPkgs = pkgs: with pkgs; [
      gdal
      geos
      libspatialite
      readline
      spatialite_tools
      uv
    ];
  };
in my-env.env
