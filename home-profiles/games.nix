{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    joycond_cemuhook
    (lutris.override {
      extraLibraries = pkgs: [
        SDL2_net
        opusfile
      ];
    })
  ];
}
