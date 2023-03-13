{ pkgs, stdenv, fetchFromGitHub, lib, ... }:
let
  nonixgl-sway = pkgs.sway.override {
    extraSessionCommands = ''
      # Test fix for external monitor being black
      export WLR_DRM_NO_MODIFIERS=1
      # Use native wayland renderer for Firefox
      export MOZ_ENABLE_WAYLAND=1
      # Use native wayland renderer for QT applications
      export QT_QPA_PLATFORM=wayland
      # Allow sway to manage window decorations
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # Use native wayland renderer for SDL applications
      export SDL_VIDEODRIVER=wayland
      # Let XDG-compliant apps know they're working on wayland
      export XDG_SESSION_TYPE=wayland
      # Fix JAVA drawing issues in sway
      export _JAVA_AWT_WM_NONREPARENTING=1
      # Let sway have access to your nix profile
      source "${pkgs.nix}/etc/profile.d/nix.sh"
    '';
    withBaseWrapper = true;
    withGtkWrapper = true;
  };
in
pkgs.runCommand "sway" {meta = {platforms = ["x86_64-linux"];};} ''
  mkdir $out

  # By default, link all top-level directories
  ln -s ${nonixgl-sway}/* $out

  # We make changes to /bin and /share, so remove those links and create dirs
  rm $out/bin
  rm $out/share
  mkdir $out/bin
  mkdir $out/share

  # Link the contents of the directory we masked
  ln -s ${nonixgl-sway}/bin/* $out/bin
  ln -s ${nonixgl-sway}/share/* $out/share

  # We have a custom sway binary, so remove that link to place a wrapper
  rm $out/bin/sway

  # Create NixGL wrapper
  echo "#!${pkgs.runtimeShell} -e" > $out/bin/sway
  echo "exec ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL" ${nonixgl-sway}/bin/sway \"\$@\" >> $out/bin/sway
  chmod +x $out/bin/sway

  # We make changes to the sessions, so remove that link and create a dir
  rm $out/share/wayland-sessions
  mkdir $out/share/wayland-sessions

  # Link all sessions
  ln -s ${nonixgl-sway}/share/wayland-sessions/* $out/share/wayland-sessions

  # We will mask just this one session file
  rm $out/share/wayland-sessions/sway.desktop

  # Create Desktop Entry for display manager
  echo [Desktop Entry] > $out/share/wayland-sessions/sway.desktop
  echo Name=Sway \(Home-Manager\) >> $out/share/wayland-sessions/sway.desktop
  echo Comment=An i3-compatible Wayland compositor >> $out/share/wayland-sessions/sway.desktop
  echo Exec=/nix/var/nix/profiles/per-user/douglas/profile/bin/sway >> $out/share/wayland-sessions/sway.desktop
  echo Type=Application >> $out/share/wayland-sessions/sway.desktop
''


