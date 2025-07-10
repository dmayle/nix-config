{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # 3D Modeling software
    openscad

    # 3D slicing software
    #cura
    prusa-slicer
  ];
}
