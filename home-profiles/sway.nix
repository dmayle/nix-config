{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Wrap native google-chrome and add the flags to run using the native wayland
  # renderer, and gnome keyring for password storage
  google-chrome-wrapper = pkgs.writeShellScriptBin "google-chrome" ''
    env XDG_CURRENT_DESKTOP=gnome \
    /usr/bin/google-chrome-stable \
      "--password-store=gnome" \
      "$@"
  '';
  # Same wrapper as above, but with the other binary name used for google-chrome
  google-chrome-stable-wrapper = pkgs.writeShellScriptBin "google-chrome-stable" ''
    env XDG_CURRENT_DESKTOP=gnome \
    /usr/bin/google-chrome-stable \
      "--password-store=gnome" \
      "$@"
  '';
in
{
  wayland.windowManager.sway = {
    enable = true;
    extraOptions = [
      "--unsupported-gpu"
      "-Dlegacy-wl-drm"
    ];
    extraSessionCommands = ''
      # Test fix for external monitor being black
      #export WLR_DRM_NO_MODIFIERS=1
      # Use native wayland renderer for Firefox
      #export MOZ_ENABLE_WAYLAND=1
      # Use native wayland renderer for QT applications
      #export QT_QPA_PLATFORM=wayland
      # Allow sway to manage window decorations
      #export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      # Use native wayland renderer for SDL applications
      #export SDL_VIDEODRIVER=wayland
      # Let XDG-compliant apps know they're working on wayland
      #export XDG_SESSION_TYPE=wayland
      # Fix JAVA drawing issues in sway
      #export _JAVA_AWT_WM_NONREPARENTING=1

      # Misc.
      #export LIBVA_DRIVER_NAME=nvidia
      #export GBM_BACKEND=nvidia-drm
      #export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export WLR_NO_HARDWARE_CURSORS=1
      #export GDK_BACKEND=wayland
      # Let sway have access to your nix profile
      # source "${pkgs.nix}/etc/profile.d/nix.sh"
    '';
    config = {
      # Set the output background to solarized base3
      output."*".bg = "#fdf6e3 solid_color";

      # If we set output resolution here, then the screen goes permanently
      # blank, so we use kanshi instead
      # output."HDMI-A-1" = {
      #   mode = "7680x4320";
      # };

      gaps = {
        smartGaps = true;
        outer = 0;
        inner = 1;
      };
      fonts = {
        names = [ "JetBrains Mono NL" ];
        size = 24.0;
      };
      window = {
        titlebar = true;
        commands = [
          {
            criteria = {
              class = "^steam$";
            };
            command = "floating enable, no_focus, move to scratchpad";
          }
          {
            criteria = {
              class = "^Firefox$";
            };
            command = "inhibit_idle fullscreen";
          }
          {
            criteria = {
              app_id = "^firefox$";
            };
            command = "inhibit_idle fullscreen";
          }
          {
            criteria = {
              class = "^Chromium$";
            };
            command = "inhibit_idle fullscreen";
          }
          {
            criteria = {
              class = "^Google-chrome$";
            };
            command = "inhibit_idle fullscreen";
          }
          {
            criteria = {
              class = "^mpv$";
            };
            command = "inhibit_idle visible";
          }
          {
            criteria = {
              app_id = "^mpv$";
            };
            command = "inhibit_idle visible";
          }
        ];
      };
      floating = {
        titlebar = true;
      };
      bars = [ ];
      focus = {
        mouseWarping = true;
        wrapping = "force";
      };
      input = {
        "4369:4369:Matias_Ergo_Pro_Keyboard" = {
          xkb_layout = "gb";
          xkb_variant = "extd";
          xkb_options = "caps:swapescape";
          xkb_numlock = "enabled";
          xkb_file = "${config.xdg.configHome}/sway/keymap_backtick.xkb";
        };
        "type:keyboard" = {
          xkb_layout = "us";
          xkb_options = "caps:swapescape";
          xkb_numlock = "enabled";
        };
      };
      modifier = "Mod4";
      terminal = "${pkgs.kitty}/bin/kitty";
      keybindings =
        let
          modifier = config.wayland.windowManager.sway.config.modifier;
        in
        lib.mkOptionDefault {
          "${modifier}+Shift+e" =
            "exec ${pkgs.sway}/bin/swaynag -t warning -m 'Exit Sway?' -b 'Exit Sway' '${pkgs.sway}/bin/swaymsg exit'";
          "${modifier}+Shift+p" = "exec loginctl lock-session";
          "${modifier}+c" = "focus child";
          "${modifier}+Shift+r" =
            "exec ${pkgs.systemd}/bin/systemctl list-units --type=service --user --plain -q | ${pkgs.coreutils}/bin/cut -d' ' -f1 | ${pkgs.wofi}/bin/wofi --dmenu | ${pkgs.findutils}/bin/xargs ${pkgs.systemd}/bin/systemctl --user restart --";
          "XF86AudioRaiseVolume" =
            "exec '${pkgs.pamixer}/bin/pamixer -ui 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'";
          "XF86AudioLowerVolume" =
            "exec '${pkgs.pamixer}/bin/pamixer -ud 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'";
          "XF86AudioMute" =
            "exec '${pkgs.pamixer}/bin/pamixer --toggle-mute && (${pkgs.pamixer}/bin/pamixer --get-mute && echo 0 > $XDG_RUNTIME_DIR/wob.sock) || ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'";
          "Print" = "exec 'flameshot gui'";
          "${modifier}+Shift+y" =
            "exec ${pkgs.sway}/bin/swaymsg output $(${pkgs.sway}/bin/swaymsg -t get_outputs | ${pkgs.jq}/bin/jq '.[] | select(.focused) | .name') enable";
          "${modifier}+Shift+n" =
            "exec ${pkgs.sway}/bin/swaymsg output $(${pkgs.sway}/bin/swaymsg -t get_outputs | ${pkgs.jq}/bin/jq '.[] | select(.focused) | .name') disable";
        };
      startup = [
        {
          command = "${pkgs.systemd}/bin/systemctl --user restart waybar";
          always = true;
        }
        {
          command = "${pkgs.systemd}/bin/systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr";
        }
        {
          command = "${pkgs.systemd}/bin/systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr";
        }
      ];

      # DMenu is a HUD (heads-up display) program launcher, but not wayland native.  This uses the waylang-native HUD launcher (wofi) with dmenu command selection
      menu = "${pkgs.dmenu}/bin/dmenu_path | ${pkgs.wofi}/bin/wofi --dmenu | ${pkgs.findutils}/bin/xargs ${pkgs.sway}/bin/swaymsg exec --";
    };
  };

}
