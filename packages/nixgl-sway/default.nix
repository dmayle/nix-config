{ pkgs, stdenv, fetchFromGitHub, lib, inputs, ... }:

pkgs.runCommand "sway" {} ''
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
  echo "exec ${nixgl.auto.nixGLDefault}/bin/nixGL" ${nonixgl-sway}/bin/sway \"\$@\" >> $out/bin/sway
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
  echo Exec=/nix/var/nix/profiles/per-user/${config.home.username}/profile/bin/sway >> $out/share/wayland-sessions/sway.desktop
  echo Type=Application >> $out/share/wayland-sessions/sway.desktop
'';


