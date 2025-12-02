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
    (gemini-cli.overrideAttrs (oldAttrs: rec {
      version = "0.18.4";
      src = fetchFromGitHub {
        owner = "google-gemini";
        repo = "gemini-cli";
        tag = "v${version}";
        hash = "sha256-TSHL3X+p74yFGTNFk9r4r+nnul2etgVdXxy8x9BjsRg=";
        # hash = "sha256-zfORrAMVozHiUawWiy3TMT+pjEaRJ/DrHeDFPJiCp38=";
      };
      npmDepsHash = "sha256-2Z6YrmUHlYKRU3pR0ZGwQbBgzNFqakBB6LYZqf66nSs=";
      # npmDepsHash = "sha256-dKaKRuHzvNJgi8LP4kKsb68O5k2MTqblQ+7cjYqLqs0=";
      npmDeps = pkgs.fetchNpmDeps {
        inherit src;
        name = "gemini-cli-${version}-npm-deps";
        hash = npmDepsHash;
      };
    }))

    # Docker Image Browser
    dive

    # Some tools for memory testing
    # (mlc.overrideAttrs (oldAttrs: rec {
    #   version = "3.11b";
    #   src = pkgs.fetchurl {
    #     url = "https://downloadmirror.intel.com/834254/mlc_v${version}.tgz";
    #     sha256 = "sha256-XVq9J9FFr1nVZMnFOTgwGgggXwdbm9QfL5K0yO/rKCQ=";
    #   };
    # }))
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
    settings = {
      user = {
        email = "douglas@mayle.org";
        name = "Douglas Mayle";
      };
      pull = {
        rebase = true;
      };
      init.defaultBranch = "main";
    };
    package = pkgs.writeTextDir "/git" "";
  };
  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
  };
}
