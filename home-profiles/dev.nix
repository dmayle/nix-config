{ pkgs, ... }:

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

    # Tool for running uv in FHS
    steam-run

    # Cmdline AI coding assistant
    gemini-cli

    # Some tools for memory testing
    (mlc.overrideAttrs (oldAttrs: rec {
      version = "3.11b";
      src = pkgs.fetchurl {
        url = "https://downloadmirror.intel.com/834254/mlc_v${version}.tgz";
        sha256 = "sha256-XVq9J9FFr1nVZMnFOTgwGgggXwdbm9QfL5K0yO/rKCQ=";
      };
    }))
    y-cruncher

    # Some VR dev tools (connecting VR to this machine)
  ];

  home.shellAliases = {
    suv = "steam-run uv";
    suvx = "steam-run uvx";
  };

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
      init.defaultBranch = "main";
    };
  };
}
