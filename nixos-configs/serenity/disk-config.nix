{ lib, ... }:
{
  disko.devices = {
    disk.disk0 = {
      # This drive is the boot drive
      device = lib.mkDefault "/dev/disk/by-id/nvme-INTEL_MEMPEK1J064GA_PHBT90860151064Q";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          encryptedSwap = {
            size = "100%";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
        };
      };
    };
    disk.disk1 = {
      device = lib.mkDefault "/dev/disk/by-id/nvme-INTEL_SSDPE21D015TA_PHKE3351007R1P5CGN";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          mdadm = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "raid0";
            };
          };
        };
      };
    };
    disk.disk2 = {
      device = lib.mkDefault "/dev/disk/by-id/nvme-INTEL_SSDPE21D015TA_PHKE336400SC1P5CGN";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          mdadm = {
            size = "100%";
            content = {
              type = "mdraid";
              name = "raid0";
            };
          };
        };
      };
    };
    mdadm = {
      raid0 = {
        type = "mdadm";
        level = 0;
        content = {
          type = "gpt";
          partitions = {
            primary = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
