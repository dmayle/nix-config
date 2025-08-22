{ pkgs, ... }:
{
  home.packages = with pkgs; [
    whisper-cpp
    lmstudio
  ];
}
