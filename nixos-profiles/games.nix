{ pkgs, config, lib, ... }: {
  environment.systemPackages = with pkgs; [
    pstree #Test
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
