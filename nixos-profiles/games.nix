{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    pstree # Test

    # For undervolting
    lact
  ];

  # Enable the systemd service in lact
  systemd.packages = with pkgs; [ lact ];

  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
