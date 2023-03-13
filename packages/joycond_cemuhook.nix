{ pkgs ? import <nixpkgs> {}, lib, fetchPypi, ... }:

pkgs.python39Packages.buildPythonPackage rec {
  pname = "joycond_cemuhook";
  version = "v20230218";

  src = pkgs.fetchgit {
    url = "https://github.com/joaorb64/joycond-cemuhook.git";
    rev = version;
    sha256 = lib.fakeSha256;
  };

  doCheck = false;

  nativeBuildInputs = with pkgs; [ pkg-config meson ninja ];
  buildInputs = with pkgs; [ libressl libxkbcommon wl-clipboard wayland wayland-protocols ];
  meta = with pkgs.lib; {
    description = "Support for cemuhook's UDP protocol for joycond devices for use with emulators";
    homepage = "https://github.com/joaorb64/joycond-cemuhook";
    licenses = license.mit;
    platforms = platforms.linux;
    maintainers = [ "douglas@mayle.org" ];
  };
}
