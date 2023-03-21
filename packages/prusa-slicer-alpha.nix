{ stdenv
, lib
, binutils
, fetchFromGitHub
, cmake
, pkg-config
, wrapGAppsHook
, boost
, cereal
, cgal_5
, curl
, dbus
, eigen
, expat
, glew
, glib
, gmp
, gtest
, gtk3
, hicolor-icon-theme
, ilmbase
, libpng
, mpfr
, nlopt
, opencascade-occt
, openvdb
, pcre
, qhull
, tbb
, wxGTK31
, xorg
, fetchpatch
, withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd, systemd
}:
let
  wxGTK-prusa = wxGTK31.overrideAttrs (old: rec {
    pname = "wxwidgets-prusa3d-patched";
    version = "3.1.4";
    src = fetchFromGitHub {
      owner = "prusa3d";
      repo = "wxWidgets";
      rev = "489f6118256853cf5b299d595868641938566cdb";
      hash = "sha256-xGL5I2+bPjmZGSTYe1L7VAmvLHbwd934o/cxg9baEvQ=";
      fetchSubmodules = true;
    };
  });
  nanosvg-source = fetchFromGitHub {
    owner = "fltk";
    repo = "nanosvg";
    rev = "abcd277ea45e9098bed752cf9c6875b533c0892f";
    sha256 = "sha256-WNdAYu66ggpSYJ8Kt57yEA4mSTv+Rvzj9Rm1q765HpY=";
  };
in
stdenv.mkDerivation rec {
  pname = "prusa-slicer";
  version = "2.6.0-alpha5";

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    binutils
    boost
    cereal
    cgal_5
    curl
    dbus
    eigen
    expat
    glew
    glib
    gmp
    gtk3
    hicolor-icon-theme
    ilmbase
    libpng
    mpfr
    nlopt
    opencascade-occt
    openvdb
    pcre
    qhull
    tbb
    wxGTK-prusa
    xorg.libX11
  ] ++ lib.optionals withSystemd [
    systemd
  ] ++ nativeCheckInputs;

  doCheck = true;
  nativeCheckInputs = [ gtest ];

  separateDebugInfo = true;

  # The build system uses custom logic - defined in
  # cmake/modules/FindNLopt.cmake in the package source - for finding the nlopt
  # library, which doesn't pick up the package in the nix store.  We
  # additionally need to set the path via the NLOPT environment variable.
  NLOPT = nlopt;

  # Disable compiler warnings that clutter the build log.
  # It seems to be a known issue for Eigen:
  # http://eigen.tuxfamily.org/bz/show_bug.cgi?id=1221
  env.NIX_CFLAGS_COMPILE = "-Wno-ignored-attributes";

  # prusa-slicer uses dlopen on `libudev.so` at runtime
  NIX_LDFLAGS = lib.optionalString withSystemd "-ludev";

  prePatch = ''
    # Since version 2.5.0 of nlopt we need to link to libnlopt, as libnlopt_cxx
    # now seems to be integrated into the main lib.
    sed -i 's|nlopt_cxx|nlopt|g' cmake/modules/FindNLopt.cmake

    # Disable test_voronoi.cpp as the assembler hangs during build,
    # likely due to commit e682dd84cff5d2420fcc0a40508557477f6cc9d3
    # See issue #185808 for details.
    sed -i 's|test_voronoi.cpp||g' tests/libslic3r/CMakeLists.txt

    # prusa-slicer expects the OCCTWrapper shared library in the same folder as
    # the executable when loading STEP files. We force the loader to find it in
    # the usual locations (i.e. LD_LIBRARY_PATH) instead. See the manpage
    # dlopen(3) for context.
    if [ -f "src/libslic3r/Format/STEP.cpp" ]; then
      substituteInPlace src/libslic3r/Format/STEP.cpp \
        --replace 'libpath /= "OCCTWrapper.so";' 'libpath = "OCCTWrapper.so";'
    fi

    cp -r ${nanosvg-source}/* deps/NanoSVG
    mv deps/NanoSVG/NanoSVG.cmake deps/NanoSVG/nanosvg-config.cmake

    # Fix resources folder location on macOS
    substituteInPlace src/PrusaSlicer.cpp \
      --replace "#ifdef __APPLE__" "#if 0"
  '' + lib.optionalString (stdenv.isDarwin && stdenv.isx86_64) ''
    # Disable segfault tests
    sed -i '/libslic3r/d' tests/CMakeLists.txt
  '';

  src = fetchFromGitHub {
    owner = "prusa3d";
    repo = "PrusaSlicer";
    sha256 = "sha256-sIbwuB1Ai2HrzN7tYm6gDL4aCppRcgjsdkuqQTTD3d0=";
    rev = "version_${version}";
  };

  cmakeFlags = [
    "-DNanoSVG_DIR=deps/NanoSVG"
    "-DSLIC3R_STATIC=0"
    "-DSLIC3R_FHS=1"
    "-DSLIC3R_GTK=3"
  ];

  postInstall = ''
    ln -s "$out/bin/prusa-slicer" "$out/bin/prusa-gcodeviewer"

    mkdir -p "$out/lib"
    mv -v $out/bin/*.* $out/lib/

    mkdir -p "$out/share/pixmaps/"
    ln -s "$out/share/PrusaSlicer/icons/PrusaSlicer.png" "$out/share/pixmaps/PrusaSlicer.png"
    ln -s "$out/share/PrusaSlicer/icons/PrusaSlicer-gcodeviewer_192px.png" "$out/share/pixmaps/PrusaSlicer-gcodeviewer.png"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/lib"
    )
  '';

  meta = with lib; {
    description = "G-code generator for 3D printer";
    homepage = "https://github.com/prusa3d/PrusaSlicer";
    license = licenses.agpl3;
    maintainers = with maintainers; [ moredread tweber ];
  } // lib.optionalAttrs (stdenv.isDarwin) {
    mainProgram = "PrusaSlicer";
  };
}
