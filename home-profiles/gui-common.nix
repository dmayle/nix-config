{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Easier to read diffs
    meld

    # Volume control used when clicking waybar
    pavucontrol
  ];

  # Speed up the mouse movement on my laptop
  xsession.initExtra = ''
    TOUCHPADID=$(xinput list | awk '/^..Virtual core pointer/,/^..Virtual core keyboard/ { FS="\t|id="; if (/Touchpad/) print $3 }')
    xinput set-prop $TOUCHPADID "libinput Accel Speed" 0.5
  '';
}
