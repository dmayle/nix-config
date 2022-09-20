{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ "${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix" ];

    boot.initrd.availableKernelModules =
      [ "nme" "xhci_pci" "ahci" "usb_storage" "sd_mod" ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.extraModulePackages = [ ];
}
