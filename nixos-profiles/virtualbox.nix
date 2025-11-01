{ pkgs, ... }:
{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "douglas" ];
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [
          virtiofsd
        ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  environment.systemPackages = with pkgs; [
    virtio-win
  ];
}
