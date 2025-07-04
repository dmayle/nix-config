{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pstree #Test
  ];
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
