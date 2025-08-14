{ ... }:

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
}
