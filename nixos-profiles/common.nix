{ pkgs, ... }:

{
  nix = {
    nixPath = [
      "nixpkgs=/etc/nixpath/nixpkgs"
    ];
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Use stylix for theming
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/solarized-light.yaml";
  };
}
