{ pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    lmstudio
  ];
}
