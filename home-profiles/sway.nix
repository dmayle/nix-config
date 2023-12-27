{ config, pkgs, lib, inputs, ... }:
let
  # This is just a default background image for the lock screen
  bgNixSnowflake = builtins.fetchurl {
    url = "https://i.imgur.com/4Xqpx6R.png";
    sha256 = "bf0d77eceef6d85c62c94084f5450e2125afc4c8eed9f6f81298771e286408ac";
  };
  # A basic lock screen script that will dim the screen after 5 minutes, lock
  # the screen and replace it with a background after 10 minutes, and turn off
  # the monitor after 15.
  idlecmd = pkgs.writeShellScript "swayidle.sh" ''
    ${pkgs.swayidle}/bin/swayidle -w \
      timeout 300 '${brightness_cmd} 20' \
        resume '${brightness_cmd} 100' \
      timeout 600 '${pkgs.swaylock}/bin/swaylock -elfF -s fill -i ${bgNixSnowflake}' \
      timeout 900 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
        resume '${pkgs.sway}/bin/swaymsg "output * dpms on" && ${brightness_cmd} 100 && /usr/bin/systemctl --user restart kanshi' \
        after-resume '${pkgs.sway}/bin/swaymsg "output * enable" && ${brightness_cmd} 100 && /usr/bin/systemctl --user restart kanshi' \
      before-sleep '${pkgs.swaylock}/bin/swaylock -elfF -s fill -i ${bgNixSnowflake}' \
      lock '${pkgs.swaylock}/bin/swaylock -elfF -s fill -i ${bgNixSnowflake}' \
      idlehint 300
  '';
  # Helper command that uses brightnessctl to update the brightness of all
  # displays at once, and display the change to the user using WOB.  It
  # supports up, down, and integer brightness levels
  brightness_cmd = pkgs.writeShellScript "brightness_change.sh" ''
    # Our variables
    BRIGHTNESS_MAX=0

    # Read list of eligible screens into bash array
    < <(${pkgs.brightnessctl}/bin/brightnessctl -l -m | grep '^[^,]*,backlight,') readarray -t SCREENS

    # Get the current maximum brightness
    for SCREEN in "''${SCREENS[@]}"; do
      PERCENT="$(echo $SCREEN | cut -d, -f4 | tr -d '%')"
      BRIGHTNESS_MAX=$((PERCENT > BRIGHTNESS_MAX ? PERCENT : BRIGHTNESS_MAX))
    done

    # Change the value as requested, rounding down to multiple of 10, and capping
    case "''${1:-up}" in
      down)
        NEW_BRIGHTNESS=$((BRIGHTNESS_MAX<10?0:BRIGHTNESS_MAX-10-BRIGHTNESS_MAX%10))
      ;;
      *[!0-9]*)
        NEW_BRIGHTNESS=$((BRIGHTNESS_MAX>90?100:BRIGHTNESS_MAX+10-BRIGHTNESS_MAX%10))
      ;;
      *)
        NEW_BRIGHTNESS=$((''${1}-''${1}%10))
      ;;
    esac


    # Set the value
    for SCREEN in "''${SCREENS[@]}"; do
      DEVICE="$(echo $SCREEN | cut -d, -f1)"
      ${pkgs.brightnessctl}/bin/brightnessctl -q -d $DEVICE set ''${NEW_BRIGHTNESS}%
    done

    # Display the value with WOB
    echo $NEW_BRIGHTNESS > $XDG_RUNTIME_DIR/wob.sock
  '';
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
  # This applies configuration to the builtin sway package
  # overridden-sway = pkgs.sway.override {
  #   # extraOptions = [ "--unsupported-gpu" ];
  #   # extraSessionCommands = ''
  #   #   # Test fix for external monitor being black
  #   #   #export WLR_DRM_NO_MODIFIERS=1
  #   #   # Use native wayland renderer for Firefox
  #   #   #export MOZ_ENABLE_WAYLAND=1
  #   #   # Use native wayland renderer for QT applications
  #   #   #export QT_QPA_PLATFORM=wayland
  #   #   # Allow sway to manage window decorations
  #   #   #export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  #   #   # Use native wayland renderer for SDL applications
  #   #   #export SDL_VIDEODRIVER=wayland
  #   #   # Let XDG-compliant apps know they're working on wayland
  #   #   #export XDG_SESSION_TYPE=wayland
  #   #   # Fix JAVA drawing issues in sway
  #   #   #export _JAVA_AWT_WM_NONREPARENTING=1
  #   #   # Fix Nvidia/Sway flickering
  #   #   export XWAYLAND_NO_GLAMOR=1

  #   #   # Misc.
  #   #   #export LIBVA_DRIVER_NAME=nvidia
  #   #   #export GBM_BACKEND=nvidia-drm
  #   #   #export __GLX_VENDOR_LIBRARY_NAME=nvidia
  #   #   export WLR_NO_HARDWARE_CURSORS=1
  #   #   #export GDK_BACKEND=wayland
  #   #   # Let sway have access to your nix profile
  #   #   source "${pkgs.nix}/etc/profile.d/nix.sh"
  #   # '';
  #   withBaseWrapper = true;
  #   withGtkWrapper = true;
  # };
in
{
  nixpkgs.config.allowUnfree = true;
  xdg.configFile."sway/keymap_backtick.xkb".source = ../keymap_backtick.xkb;
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true;
  systemd.user.targets.tray = {
    Unit = {
      Description = "Home Manager System Tray";
      Requires = [ "graphical-session-pre.target" ];
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    #package = overridden-sway;
    extraOptions = [ "--unsupported-gpu" ];
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
      # Fix Nvidia/Sway flickering
      export XWAYLAND_NO_GLAMOR=1

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
      gaps = {
        smartGaps = true;
        outer = 0;
        inner = 1;
      };
      window = {
        titlebar = true;
        commands = [
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
      bars = [];
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
      keybindings = let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "${modifier}+Shift+e" = "exec ${pkgs.sway}/bin/swaynag -t warning -m 'Exit Sway?' -b 'Exit Sway' '${pkgs.sway}/bin/swaymsg exit'";
        "${modifier}+Shift+p" = "exec loginctl lock-session";
        "${modifier}+c" = "focus child";
        "${modifier}+Shift+r" =  "exec /usr/bin/systemctl list-units --type=service --user --plain -q | /usr/bin/cut -d' ' -f1 | ${pkgs.wofi}/bin/wofi --dmenu | ${pkgs.findutils}/bin/xargs /usr/bin/systemctl --user restart --";
        "XF86AudioRaiseVolume" = "exec '${pkgs.pamixer}/bin/pamixer -ui 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'";
        "XF86AudioLowerVolume" = "exec '${pkgs.pamixer}/bin/pamixer -ud 2 && ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'";
        "XF86AudioMute" = "exec '${pkgs.pamixer}/bin/pamixer --toggle-mute && (${pkgs.pamixer}/bin/pamixer --get-mute && echo 0 > $XDG_RUNTIME_DIR/wob.sock) || ${pkgs.pamixer}/bin/pamixer --get-volume > $XDG_RUNTIME_DIR/wob.sock'";
        "Print" = "exec 'flameshot gui'";
        "F5" = "exec '${brightness_cmd} down'";
        "F6" = "exec '${brightness_cmd} up'";
      };
      startup = [
        # Send GUI DISPLAY VARIABLES into dbus to enable things like gnome-keyring-daemon to use user prompts
        {
          command = "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP=sway";
        }
      ];

      # DMenu is a HUD (heads-up display) program launcher, but not wayland native.  This uses the waylang-native HUD launcher (wofi) with dmenu command selection
      menu = "${pkgs.dmenu}/bin/dmenu_path | ${pkgs.wofi}/bin/wofi --dmenu | ${pkgs.findutils}/bin/xargs ${pkgs.sway}/bin/swaymsg exec --";
    };
    extraConfig = ''
      bindswitch lid:on output eDP-1 disable
      bindswitch lid:off output eDP-1 enable
      bindsym --locked Mod4+Shift+s exec ${pkgs.sway}/bin/swaymsg output eDP-1 enable
      bindsym --locked Mod4+Shift+y exec ${pkgs.sway}/bin/swaymsg output $(${pkgs.sway}/bin/swaymsg -t get_outputs |  ${pkgs.jq}/bin/jq '.[] | select(.focused) | .name') enable
      bindsym --locked Mod4+Shift+n exec ${pkgs.sway}/bin/swaymsg output $(${pkgs.sway}/bin/swaymsg -t get_outputs |  ${pkgs.jq}/bin/jq '.[] | select(.focused) | .name') disable
    '';
  };
  services.kanshi = {
    enable = true;
    profiles = {
      home_office = {
        outputs = [
          {
            criteria = "Unknown 0x4141 0x00000000";
            transform = "normal";
            status = "disable";
          }
          {
            criteria = "Technical Concepts Ltd 65R648 0x00000000";
            mode = "3840x2160";
            position = "0,0";
            transform = "normal";
            status = "enable";
          }
        ];
      };
      undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            transform = "normal";
            position = "0,0";
          }
        ];
      };
      anza = {
        outputs = [
          {
            criteria = "Unknown 0x4141 0x00000000";
            transform = "normal";
            status = "disable";
          }
          {
            criteria = "Lenovo Group Limited LEN P32p-20 VNA65XZA";
            mode = "3840x2160";
            transform = "270";
            position = "2160,0";
            status = "enable";
          }
          {
            criteria = "Lenovo Group Limited LEN P32p-20 VNA4Y6P6";
            mode = "3840x2160";
            transform = "90";
            position = "0,0";
            status = "enable";
          }
        ];
      };
      anza_left_only = {
        outputs = [
          {
            criteria = "Unknown 0x4141 0x00000000";
            transform = "normal";
            status = "disable";
          }
          {
            criteria = "Lenovo Group Limited LEN P32p-20 VNA4Y6P6";
            mode = "3840x2160";
            transform = "90";
            position = "0,0";
            status = "enable";
          }
        ];
      };
      anza_right_only = {
        outputs = [
          {
            criteria = "Unknown 0x4141 0x00000000";
            transform = "normal";
            status = "disable";
          }
          {
            criteria = "Lenovo Group Limited LEN P32p-20 VNA65XZA";
            mode = "3840x2160";
            transform = "270";
            position = "0,0";
            status = "enable";
          }
        ];
      };
    };
  };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 48;
        modules-left = [
          "sway/mode"
          "sway/workspaces"
          "custom/right-blue-background"
        ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "idle_inhibitor"
          "custom/left-yellow-background"
          "pulseaudio"
          "custom/left-magenta-yellow"
          "battery"
          "custom/left-base03-magenta"
          "tray"
          "clock#date"
          "custom/left-base3-base03"
          "clock#time"
        ];
        "clock#date" = {
          interval = 20;
          format = "{:%e %b %Y}";
          tooltip = false;
        };
        "clock#time" = {
          interval = 10;
          format = "{:%H:%M}";
          tooltip = false;
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "☕";
            deactivated = "🥱";
          };
        };
        battery = {
            states = {
                # "good" = 95;
                warning = 30;
                critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{time} {icon}";
            # "format-good" = "", # An empty format will hide the module
            # "format-full" = "";
            format-icons = ["" "" "" "" ""];
        };
        "battery#bat2" = {
          bat = "BAT2";
        };
        "network" = {
          interval = 5;
          format-wifi = "📶 {essid} ({signalStrength}%)";
          format-ethernet = "🛰️ {ifname}: {ipaddr}/{cidr}";
          format-disconnected = "DISCONNECTED";
          tooltip = false;
        };
        "sway/mode" = {
          format = "⚠️ <span style=\"italic\">{}</span>";
          tooltip = false;
        };
        "sway/window" = {
          format = "{}";
          max-length = 30;
          tooltip = false;
        };
        "sway/workspaces" = {
          all-outputs = false;
          disable-scroll = false;
          format = " {name} ";
        };
        "pulseaudio" = {
          scroll-step = 2;
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{icon} {volume}%";
          format-muted = "🔇 ❌ {format_source}";
          format-source = "🎙️ {volume}%";
          format-source-muted = "🎙️ ❌";
          format-icons = {
            headphones = "🎧";
            handsfree = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "🔈" "🔉" "🔊" ];
          };
          on-click = "pavucontrol";
        };
        tray = {
          icon-size = 21;
        };
        "custom/right-blue-background" = {
          format = "";
          tooltip = false;
        };
        # "custom/right-cyan-background" = {
        #   format = "";
        #   tooltip = false;
        # };
        "custom/left-base3-base03" = {
          format = "";
          tooltip = false;
        };
        "custom/left-base03-magenta" = {
          format = "";
          tooltip = false;
        };
        "custom/left-magenta-yellow" = {
          format = "";
          tooltip = false;
        };
        "custom/left-yellow-background" = {
          format = "";
          tooltip = false;
        };
      }
    ];
    style = ''
      @keyframes blink-warning {
          70% {
              color: @base2;
          }
          to {
              color: @base2;
              background-color: @magenta;
          }
      }
      @keyframes blink-critical {
          70% {
              color: @base2;
          }
          to {
              color: @base2;
              background-color: @red;
          }
      }
      @keyframes battery-blink-warning {
          70% {
              color: @magenta;
              background-color: @magenta;
          }
          to {
              color: @base3;
              background-color: @magenta;
          }
      }
      @keyframes battery-blink-critical {
          70% {
              color: @base3;
              background-color: @magenta;
          }
          to {
              color: @base3;
              background-color: @red;
          }
      }
      /* Solarized */
      @define-color base03 #002b36;
      @define-color base02 #073642;
      @define-color base01 #586e75;
      @define-color base00 #657b83;
      @define-color base0 #839496;
      @define-color base1 #93a1a1;
      @define-color base2 #eee8d5;
      @define-color base3 #fdf6e3;
      @define-color yellow #b58900;
      @define-color orange #cb4b16;
      @define-color red #dc322f;
      @define-color magenta #d33682;
      @define-color violet #6c71c4;
      @define-color blue #268bd2;
      @define-color cyan #2aa198;
      @define-color green #859900;
      /* Reset all styles */
      * {
          border: none;
          border-radius: 0;
          min-height: 0;
          margin: 0;
          padding: 0;
          font-family: DroidSansMono, Roboto, Helvetica, Arial, sans-serif;
          font-size: 24pt;
      }
      /* The whole bar */
      #waybar {
          background: transparent;
          color: @base2;
          font-family: Terminus, Siji;
          font-size: 30pt;
          /*font-weight: bold;*/
      }
      /* Each module */
      #battery,
      #clock,
      #cpu,
      #language,
      #memory,
      #mode,
      #network,
      #pulseaudio,
      #temperature,
      #custom-alsa,
      #sndio,
      #tray {
          padding-left: 10px;
          padding-right: 10px;
      }
      /* Each module that should blink */
      #mode,
      #memory,
      #temperature,
      #battery {
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }
      /* Each critical module */
      #memory.critical,
      #cpu.critical,
      #temperature.critical,
      #battery.critical {
          animation-name: battery-blink-critical;
          animation-duration: 3s;
      }
      /* Each critical that should blink */
      #mode,
      #memory.critical,
      #temperature.critical,
      #battery.critical.discharging {
          animation-name: blink-critical;
          animation-duration: 2s;
      }
      /* Each warning */
      #network.disconnected,
      #memory.warning,
      #cpu.warning,
      #temperature.warning,
      #battery.warning {
          animation-name: battery-blink-warning;
          animation-duration: 3s;
      }
      /* Each warning that should blink */
      #battery.warning.discharging {
          animation-name: blink-warning;
          animation-duration: 3s;
      }
      /* And now modules themselves in their respective order */
      #mode { /* Shown current Sway mode (resize etc.) */
          color: @base2;
          background: @mode;
      }
      /* Workspaces stuff */
      #workspaces button {
          /*font-weight: bold;*/
          padding-left: 4px;
          padding-right: 4px;
          color: @base3;
          background: @cyan;
      }
      #workspaces button.focused {
          background: @blue;
      }
      /*#workspaces button.urgent {
          border-color: #c9545d;
          color: #c9545d;
      }*/
      #window {
          margin-right: 40px;
          margin-left: 40px;
      }
      #custom-alsa,
      #pulseaudio,
      #sndio {
          background: @yellow;
          color: @base2;
      }
      #network {
          background: @magenta;
          color: @base2;
      }
      #memory {
          background: @memory;
          color: @base03;
      }
      #cpu {
          background: @cpu;
          color: @base2;
      }
      #temperature {
          background: @temp;
          color: @base03;
      }
      #language {
          background: @layout;
          color: @base2;
      }
      #battery {
          background: @magenta;
          color: @base2;
      }
      #tray {
          background: @date;
      }
      #clock.date {
          background: @base03;
          color: @base2;
      }
      #clock.time {
          background: @base3;
          color: @base03;
      }
      #pulseaudio.muted {
          /* No styles */
      }
      #custom-right-blue-background {
          font-size: 38px;
          color: @blue;
          background: transparent;
      }
      #custom-right-cyan-background {
          font-size: 38px;
          color: @cyan;
          background: transparent;
      }
      #custom-left-base3-base03 {
          font-size: 38px;
          color: @base3;
          background: @base03;
      }
      #custom-left-base03-magenta {
          font-size: 38px;
          color: @base03;
          background: @magenta;
      }
      #custom-left-magenta-yellow {
          font-size: 38px;
          color: @magenta;
          background: @yellow;
      }
      #custom-left-yellow-background {
          font-size: 38px;
          color: @yellow;
          background: transparent;
      }
    '';
  };
  # Mako is a DBUS-activated desktop notifications daemon for wayland
  services.mako = {
    enable = true;
  };
  systemd.user.services.mako = {
    Unit = {
      Description = "Mako notification daemon";
      PartOf = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      RestartSec = 5;
      Restart = "always";
    };
  };
  # WOB (Wayland Overlay Bar) is a simple progress bar that displays in the
  # center of the screen briefly.  It's used to give the user (you) visual
  # confirmation that the volume key you pressed had the desired effect.  It
  # can also be used for screen brightness or just about anything else you'd
  # like to connect to it... (e.g. dd progress)
  systemd.user.services.wob = {
    Unit = {
      Description = "A lightweight overlay volume/backlight/progress/anything bar for Wayland";
      Documentation = "man:wob(1)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wob}/bin/wob -O '*'";
      StandardInput = "socket";
    };
  };
  systemd.user.services.plugged_in_suspend_inhibitor = {
    Service = {
      ExecStart = "systemd-inhibit sleep infinity";
      Restart = "always";
      RestartSec = 3;
    };
  };
  systemd.user.sockets.wob = {
    Install = {
      WantedBy = [ "sockets.target" ];
    };
    Socket = {
      ListenFIFO = "%t/wob.sock";
      SocketMode = "0600";
    };
  };
  # Setup screensaver / lock with swayidle and swaylock
  systemd.user.services.swayidle = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      Description = "Screenlock with SwayIdle and SwayLock";
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
    Service = {
      ExecStart = "${idlecmd}";
      Restart = "always";
      RestartSec = 3;
    };
  };
  # LXPolkit is a GUI policy kit client that will prompt the user for their
  # password when attempting to run GUI programs that need privelege
  # escalation. You can test it out with the following shell command:
  # `pkexec echo Hello from root`
  systemd.user.services.lxpolkit = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      Description = "Policykit agent for privilege escalation (ie. gui sudo)";
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
    Service = {
      ExecStart = "lxpolkit";
      Restart = "always";
      RestartSec = 3;
    };
  };
  # Start and run the goobuntu indicator that shows the status of the environment
  systemd.user.services.goobuntu_indicator = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      Description = "Goobuntu Indicator";
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
    Service = {
      ExecStart = "env XDG_CURRENT_DESKTOP=gnome /usr/share/goobuntu-indicator/goobuntu_indicator.py";
      Restart = "always";
      RestartSec = 3;
    };
  };
  services.wlsunset = {
    enable = true;
    latitude = "37.7";
    longitude = "-122.5";
    systemdTarget = "sway-session.target";
  };

  home.packages = with pkgs; [
    kitty
    google-chrome
    dmenu
    wofi
    waybar
    #brightnessctl
    ddcutil
    tree-sitter
    flameshot
    grim
    slurp
    i2c-tools
    kanshi
    pamixer
    pulseaudio
    wl-clipboard
    wob
    xorg.xhost
    qownnotes
    xdg-utils
    glib
    #gnome3.adwaita-icon-theme
    #xdg-desktop-portal-gtk
    #xdg-desktop-portal-wlr
  ];
}
