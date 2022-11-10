{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    (lutris.override {
      extraLibraries = pkgs: [
        SDL2_net
        opusfile
      ];
    })
  ];
}
