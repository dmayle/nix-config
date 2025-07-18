{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ "${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix" ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.blacklistedKernelModules = [ "cdc_ether" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_15;
  boot.kernelParams = [
    "pcie_aspm=off"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-id/md-name-any:raid0-part1";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-partlabel/disk-disk0-ESP";
      fsType = "vfat";
    };

  # swapDevices =
  #   [ { device = "/dev/disk/by-label/swap"; }
  #   ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp36s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp38s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp39s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp42s0f3u5u3c2.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # high-resolution display
  #hardware.video.hidpi.enable = lib.mkDefault true;
}
