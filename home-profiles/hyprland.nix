{ config, pkgs, lib, inputs, ... }:
let
  # This is just a default background image for the lock screen
  bgNixSnowflake = builtins.fetchurl {
    url = "https://i.imgur.com/4Xqpx6R.png";
    sha256 = "bf0d77eceef6d85c62c94084f5450e2125afc4c8eed9f6f81298771e286408ac";
  };
  flameshotGrim = pkgs.flameshot.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "flameshot-org";
      repo = "flameshot";
      rev = "3d21e4967b68e9ce80fb2238857aa1bf12c7b905";
      sha256 = "sha256-OLRtF/yjHDN+sIbgilBZ6sBZ3FO6K533kFC1L2peugc=";
    };
    cmakeFlags = [
      "-DUSE_WAYLAND_CLIPBOARD=1"
      "-DUSE_WAYLAND_GRIM=1"
    ];
    buildInputs = oldAttrs.buildInputs ++ [ pkgs.libsForQt5.kguiaddons ];
  });
  service-restart-command = "service-restart";
  serviceRestart = pkgs.writeShellScriptBin service-restart-command ''
        ${pkgs.systemd}/bin/systemctl list-units --type=service --user --plain -q | ${pkgs.coreutils}/bin/cut -d' ' -f1 | ${pkgs.fuzzel}/bin/fuzzel --dmenu | ${pkgs.findutils}/bin/xargs ${pkgs.systemd}/bin/systemctl --user restart --
  '';
  wlogout-command = "wlogout-wrapped";
  wlogoutWrapped = pkgs.writeShellScriptBin wlogout-command ''
    ${pkgs.procps}/bin/pgrep -x "wlogout" > /dev/null && ${pkgs.procps}/bin/pkill -x "wlogout" && exit 0
    export LAYOUT="''${XDG_CONFIG_HOME:-$HOME/.config}/wlogout/layout"
    export STYLE="''${XDG_CONFIG_HOME:-$HOME/.config}/wlogout/style.css"

    export SCREEN_HEIGHT=$(${pkgs.hyprland}/bin/hyprctl -j monitors | ${pkgs.jq}/bin/jq '.[] | select(.focused==true) | .height')
    export SCREEN_WIDTH=$(${pkgs.hyprland}/bin/hyprctl -j monitors | ${pkgs.jq}/bin/jq '.[] | select(.focused==true) | .width')
    export SCREEN_SCALE=$(${pkgs.hyprland}/bin/hyprctl -j monitors | ${pkgs.jq}/bin/jq '.[] | select(.focused==true) | .scale' | ${pkgs.gnused}/bin/sed 's/\.//')

    # Calculate as percentages of screen height
    export MARGIN=$((SCREEN_HEIGHT * 40 / SCREEN_SCALE))
    export TEXT_OFFSET=$((SCREEN_HEIGHT * 8 / SCREEN_SCALE))
    export HOVER=$((SCREEN_HEIGHT * 35 / SCREEN_SCALE))
    export HOVER_TEXT_OFFSET=$((SCREEN_HEIGHT * 124 / SCREEN_SCALE / 10))

    export FONT_SIZE=$((SCREEN_HEIGHT * 3 / 100))

    export BORDER=12 # or 10, arbitrary preference
    export ACTIVE_RADIUS=$((BORDER * 5))
    export BUTTON_RADIUS=$((BORDER * 8))

    export BUTTON_COLOR=''${1:-magenta}

    ${pkgs.wlogout}/bin/wlogout \
      --buttons-per-row 4 \
      --column-spacing 0 \
      --row-spacing 0 \
      --margin 0 \
      --layout $LAYOUT \
      --css <(${pkgs.envsubst}/bin/envsubst < $STYLE) \
      --protocol layer-shell
  '';
in
{
  # This is only here because I want to share the package override with a keybinding
  services.flameshot = {
    enable = true;
    package = flameshotGrim;
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.numix-solarized-gtk-theme;
      name = "NumixSolarizedLightMagenta";
    };
    iconTheme = {
      package = pkgs.numix-icon-theme;
      name = "Numix";
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
    package = inputs.hyprland.packages.x86_64-linux.hyprland;
    systemd.enable = true;
    plugins = [ inputs.hy3.packages.x86_64-linux.hy3 ];
    extraConfig = ''
    '';
    settings = {
      exec-once = [
        "${pkgs.systemd}/bin/systemctl --user import-environment"
      ];
      "$terminal" = "${pkgs.kitty}/bin/kitty";
      "$fileManager" = "${pkgs.libsForQt5.dolphin}/bin/dolphin";
      "$menu" = "${pkgs.fuzzel}/bin/fuzzel";
      "$mod" = "SUPER";
      "$modShift" = "SUPERSHIFT";
      #monitor = "HDMI-A-1,7680x4320@59.940,0x0,1";
      debug = {
        disable_logs = false;
      };
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_VENDOR_LIBRARY_NAME,nvidia"
        "WLR_NO_HARDWARE_CURSORS,1"
        "HYPRLAND_LOG_WLR,1"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
      ];
      bind = [
        # Terminal, menu
        "$mod, Return, exec, $terminal"
        "$mod, d, exec, $menu"

        # Move to workspace
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move window to workspace
        "$modShift, 1, movetoworkspace, 1"
        "$modShift, 2, movetoworkspace, 2"
        "$modShift, 3, movetoworkspace, 3"
        "$modShift, 4, movetoworkspace, 4"
        "$modShift, 5, movetoworkspace, 5"
        "$modShift, 6, movetoworkspace, 6"
        "$modShift, 7, movetoworkspace, 7"
        "$modShift, 8, movetoworkspace, 8"
        "$modShift, 9, movetoworkspace, 9"
        "$modShift, 0, movetoworkspace, 10"

        # Move focus
        "$mod, left, hy3:movefocus, l"
        "$mod, down, hy3:movefocus, d"
        "$mod, up, hy3:movefocus, u"
        "$mod, right, hy3:movefocus, r"
        "$mod, h, hy3:movefocus, l"
        "$mod, j, hy3:movefocus, d"
        "$mod, k, hy3:movefocus, u"
        "$mod, l, hy3:movefocus, r"

        # Move focus parent (raise), child (lower)
        "$mod, a, hy3:changefocus, raise"
        "$mod, c, hy3:changefocus, lower"

        # Splits
        "$mod, b, hy3:makegroup, h"
        "$mod, v, hy3:makegroup, v"

        # Group controls
        "$mod, w, hy3:changegroup, tab"
        "$mod, s, hy3:changegroup, untab"
        "$mod, e, hy3:changegroup, opposite"

        # Move window
        "$modShift, left, hy3:movewindow, l"
        "$modShift, down, hy3:movewindow, d"
        "$modShift, up, hy3:movewindow, u"
        "$modShift, right, hy3:movewindow, r"
        "$modShift, h, hy3:movewindow, l"
        "$modShift, j, hy3:movewindow, d"
        "$modShift, k, hy3:movewindow, u"
        "$modShift, l, hy3:movewindow, r"

        # Show notifications
        "$modShift, n, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw"

        # Scratchpad
        "$mod, minus, togglespecialworkspace, magic"

        "$modShift, minus, movetoworkspace, special:magic"
        "$modShift, minus, togglefloating"

        "$modShift, space, togglefloating"

        # Close uncloseable window
        "$modShift, q, killactive"

        # Maximized (f) and full-screen (shift-f)
        "$mod, f, fullscreen, 1"
        "$modShift, f, fullscreen, 0"

        # Print Screen
        ", Print, exec, ${flameshotGrim}/bin/flameshot gui"

        # Session helpers
        "$modShift, p, exec, ${pkgs.systemd}/bin/loginctl lock-session"
        "$modShift, e, exec, ${wlogoutWrapped}/bin/${wlogout-command}"

        "$modShift, r, exec, ${serviceRestart}/bin/${service-restart-command}"
      ];
      bindle = [
        ",XF86AudioRaiseVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume raise"
        ",XF86AudioLowerVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume lower"
        ",XF86AudioMute, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle"
      ];
      bindr = [
        ", Caps_Lock, exec, ${pkgs.swayosd}/bin/swayosd-client --caps-lock"
      ];
      general = {
        layout = "hy3";
      };
      "device:matias-ergo-pro-keyboard" = {
        #name = "matias-ergo-pro-keyboard";
        kb_layout = "gb";
        kb_variant = "extd";
        kb_options = "caps:swapescape";
        numlock_by_default = true;
        kb_file = "${config.xdg.configHome}/keymap_backtick.xkb";
      };
      "device:keychron-keychron-q11" = {
        kb_layout = "gb";
        kb_variant = "extd";
        kb_options = "caps:swapescape";
        numlock_by_default = true;
        kb_file = "${config.xdg.configHome}/keymap_backtick.xkb";
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
