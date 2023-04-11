{ pkgs, config, lib, ... }: {
  environment.systemPackages = with pkgs; [
    pstree #Test
  ];
  #joycond is necessary for gyro with cemu, but prevents gyro in Steam
  #services.joycond.enable = true;
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
