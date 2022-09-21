{ pkgs ? import <nixpkgs> {}, ... }:

pkgs.stdenv.mkDerivation rec {
  name = "waynergy";
  version = "v0.0.12";

  src = pkgs.fetchgit {
    url = "https://github.com/r-c-f/waynergy.git";
    rev = version;
    sha256 = "sha256-RQNzRuM+3HDw2TM2zfiZjB5uAa94HezC6ewg6vign/0=";
  };

  nativeBuildInputs = with pkgs; [ pkg-config meson ninja ];
  buildInputs = with pkgs; [ libressl libxkbcommon wl-clipboard wayland wayland-protocols ];
  meta = with pkgs.lib; {
    description = "Synergy client for Wayland";
    homepage = "https://github.com/r-c-f/waynergy";
    licenses = license.mit;
    platforms = platforms.linux;
    maintainers = [ "dougle@google.com" ];
  };
}
