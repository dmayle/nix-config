{ config, pkgs, lib, inputs, ... }:
let
  # This is just a default background image for the lock screen
  bgNixSnowflake = builtins.fetchurl {
    url = "https://i.imgur.com/4Xqpx6R.png";
    sha256 = "bf0d77eceef6d85c62c94084f5450e2125afc4c8eed9f6f81298771e286408ac";
  };
in
{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };
  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Adwaita";
      #name = "Flat-Remix-GTK-Grey-Darkest";
    };
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
    font = {
      name = "Sans";
      size = 11;
    };
  };
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        width = 45;
        line-height = 50;
        fields = "name,generic,comment,categories,filename,keywords";
        prompt = "❯   ";
      };
      border = {
        radius = 20;
      };
      dmenu = {
        exit-immediately-if-empty = true;
      };
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = [];
    extraConfig = ''
    '';
    settings = {
      "$terminal" = "${pkgs.kitty}/bin/kitty";
      "$fileManager" = "${pkgs.libsForQt5.dolphin}/bin/dolphin";
      "$menu" = "${pkgs.wofi}/bin/wofi --show drun";
      "$mod" = "SUPER";
      "$modShift" = "SUPERSHIFT";
      #monitor = "HDMI-A-1,7680x4320@59.940,0x0,1";
      env = [
        "WLR_NO_HARDWARE_CURSORS,1"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
      ];
      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, d, exec, ${pkgs.fuzzel}/bin/fuzzel -I"
        "$modShift, p, exec, ${pkgs.swaylock-effects}/bin/swaylock"
        "$modShift, e, exec, ${pkgs.hyprland}/bin/hyprctl dispatch exit"
      ];
      "device:matias-ergo-pro-keyboard" = {
        #name = "matias-ergo-pro-keyboard";
        kb_layout = "gb";
        kb_variant = "extd";
        kb_options = "caps:swapescape";
        numlock_by_default = true;
        kb_file = "${config.xdg.configHome}/sway/keymap_backtick.xkb";
      };
      input = {
        kb_layout = "us";
        kb_options = "caps:swapescape";
        numlock_by_default = true;
      };
    };
  };
  systemd.user.services.plugged_in_suspend_inhibitor = {
    Service = {
      ExecStart = "systemd-inhibit sleep infinity";
      Restart = "always";
      RestartSec = 3;
    };
  };

  home.packages = with pkgs; [
    dolphin
  ];
}
