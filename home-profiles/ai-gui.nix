{ pkgs, ... }:
let
  whisper176 = pkgs.whisper-cpp.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "ggml-org";
      repo = "whisper.cpp";
      rev = "a8d002cfd879315632a579e73f0148d06959de36";
      sha256 = "sha256-dppBhiCS4C3ELw/Ckx5W0KOMUvOHUiisdZvkS7gkxj4=";
    };
  });
in
{
  home.packages = [
    whisper176
  ];
}
