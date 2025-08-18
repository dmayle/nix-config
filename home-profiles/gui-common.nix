{ pkgs, ... }:

{
  nixpkgs.config = {
    cudaSupport = true;
  };

  home.packages = with pkgs; [
    # Easier to read diffs
    meld

    # Volume control used when clicking waybar
    pwvucontrol

    # pipe to and from X clipboard
    xsel
    wl-clipboard

    libreoffice

    # Add Godoto Game Development engine
    godot_4

    kitty
    google-chrome
    firefox
    tree-sitter
    vulkan-tools
    glxinfo
    pamixer
    pulseaudio
    qownnotes
    xdg-utils
  ];

  # Speed up the mouse movement on my laptop
  xsession.initExtra = ''
    TOUCHPADID=$(xinput list | awk '/^..Virtual core pointer/,/^..Virtual core keyboard/ { FS="\t|id="; if (/Touchpad/) print $3 }')
    xinput set-prop $TOUCHPADID "libinput Accel Speed" 0.5
  '';

  # Configure solarized light color scheme for kitty
  programs.kitty = {
    enable = true;
    shellIntegration.mode = "no-cursor";
    extraConfig = ''
      cursor_shape block
      enable_audio_bell no
      # Solarized Light Colorscheme

      background              #fdf6e3
      foreground              #657b83
      cursor                  #586e75

      selection_background    #475b62
      selection_foreground    #eae3cb

      color0                #073642
      color8                #002b36

      color1                #dc322f
      color9                #cb4b16

      color2                #859900
      color10               #586e75

      color3                #b58900
      color11               #657b83

      color4                #268bd2
      color12               #839496

      color5                #d33682
      color13               #6c71c4

      color6                #2aa198
      color14               #93a1a1

      color7                #eee8d5
      color15               #fdf6e3

      # Setup font size controls, For 8k 65", 18.0 is good, for 4k 65", 10.0 is good
      font_size 18.0
      map kitty_mod+0 set_font_size 18.0
      map kitty_mod+equal change_font_size all +2.0
      map kitty_mod+minus change_font_size all -2.0
    '';
  };

}
