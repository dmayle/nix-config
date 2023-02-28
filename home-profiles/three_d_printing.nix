{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # 3D Modeling software
    openscad

    # 3D slizing software
    cura
    super-slicer-latest
    prusa-slicer
  ];
}
