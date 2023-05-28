{ config, pkgs, lib, ... }:

{
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };
}
