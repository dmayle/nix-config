{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Might not be permanent, but I find it useful
    gdb

    git

    # Per-directory dev setup
    direnv

    # Fantastic interface for breaking up commits into better units
    git-crecord

    # Kubernetes tools
    kubectx

    # Hetzner tools
    hcloud

    # Secret management
    # Python dev env management
    uv
  ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.writeTextDir "/git" "";
    userName = "Douglas Mayle";
    userEmail = "douglas@mayle.org";
    diff-so-fancy = {
      enable = true;
    };
    extraConfig = {
      pull = {
        rebase = true;
      };
    };
  };
}
