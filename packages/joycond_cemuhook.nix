{ pkgs ? import <nixpkgs> {}, lib, fetchPypi, ... }:

pkgs.python39Packages.buildPythonPackage rec {
  pname = "joycond_cemuhook";
  version = "v20230218";
  format = "pyproject";

  src = pkgs.fetchgit {
    url = "https://github.com/joaorb64/joycond-cemuhook.git";
    rev = "d488022d4392a24753f1bc203f1f6e286656910b";
    sha256 = "sha256-SmT3scLHcevSjiXmVHau24KNsGwGNDVk1mhnuDYRGgc=";
  };

  propagatedBuildInputs = with pkgs.python39Packages; [
    setuptools
    pyudev
    evdev
    termcolor
    dbus-python
    setuptools-git-versioning
  ];

  postPatch = ''
  substituteInPlace pyproject.toml \
    --replace '"argparse",' ' ' \
    --replace '"asyncio",' ' '
'';

  doCheck = false;

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ ];
  meta = with pkgs.lib; {
    description = "Support for cemuhook's UDP protocol for joycond devices for use with emulators";
    homepage = "https://github.com/joaorb64/joycond-cemuhook";
    licenses = license.mit;
    platforms = platforms.linux;
    maintainers = [ "douglas@mayle.org" ];
  };
}
