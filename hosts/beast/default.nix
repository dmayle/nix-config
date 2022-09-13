{ pkgs, config, lib, ... }:
let
  foo = "bar";
in
{
  imports = [ ./hardware-configuration.nix ];

  time.timeZone = "Americas/Los_Angeles";

  nixpkgs.config.allowUnfree = true;
}
