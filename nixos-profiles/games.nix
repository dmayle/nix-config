{ pkgs, config, lib, ... }: {
  environment.systemPackages = with pkgs; [
    pstree #Test
  ];
  services.joycond.enable = true;
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
