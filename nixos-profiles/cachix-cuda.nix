{ pkgs, config, lib, ... }: {
  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E"
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    python3Packages.tensorflowWithCuda
  ];
}
