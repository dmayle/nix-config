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
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0"
    "pci_aspm=performance"
  ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/926123e8-1385-4dab-8a9f-5a18b4421501";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/1552-D9E7";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9b4ef403-5cb4-4e64-a8f3-e5cd111a22f2"; }
    ];

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
}
