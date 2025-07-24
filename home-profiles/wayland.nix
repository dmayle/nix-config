{ pkgs, inputs, ... }:
let
  hyprlandPackage = inputs.hyprland.packages.x86_64-linux.hyprland;
  hyprlandPortal = inputs.hyprland.packages.x86_64-linux.xdg-desktop-portal-hyprland;
  # This is just a default background image for the lock screen
  bgNixSnowflake = builtins.fetchurl {
    url = "https://i.imgur.com/4Xqpx6R.png";
    sha256 = "bf0d77eceef6d85c62c94084f5450e2125afc4c8eed9f6f81298771e286408ac";
  };
in
{
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "${pkgs.systemd}/bin/loginctl lock-session";
        # Material design icon text name
        text = "lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "${hyprlandPackage}/bin/hyprctl dispatch exit";
        # Material design icon text name
        text = "logout";
        keybind = "l";
      }
      {
        label = "shutdown";
        action = "${pkgs.systemd}/bin/systemctl poweroff";
        # Material design icon text name
        text = "power_settings_new";
        keybind = "l";
      }
      {
        label = "reboot";
        action = "${pkgs.systemd}/bin/systemctl reboot";
        # Material design icon text name
        text = "restart_alt";
        keybind = "l";
      }
    ];
    # This style uses environment variables passed by the wlogoutWrapped script in hyprland.nix
    style = ''
      * {
        background-image: none;
        font-size: ''${FONT_SIZE}px;
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

      @define-color button-text @base3;
      @define-color button-background @base03;
      @define-color button-background-focused @base01;
      @define-color button-background-hover @''${BUTTON_COLOR:-magenta};

      window {
        background-color: rgba(0, 0, 0, 0);
      }

      button {
        font-family: 'Material Symbols Outlined';
        color: @button-text;
        background-color: @button-background;
        outline-style: none;
        border: none;
        border-width: 0;
        background-repeat: no-repeat;
        background-position: center;
        border-radius: 0;
        padding-bottom: ''${TEXT_OFFSET}px;
        box-shadow: none;
        text-shadow: none;
        animation: gradient_f 20s ease-in infinite;
        /* default margin rule (excluding ends) */
        margin: ''${MARGIN}px 0 ''${MARGIN}px 0;
      }

      button:focus {
        background-color: @button-background-focused;
      }

      button:hover {
        background-color: @button-background-hover;
        border-radius: ''${ACTIVE_RADIUS}px;
        padding-bottom: ''${HOVER_TEXT_OFFSET}px;
        animation: gradient_f 20s ease-in infinite;
        transition: all 0.3s cubic-bezier(.55,0.0,.28,1.682);
        /* default margin rule (excluding ends) */
        margin: ''${HOVER}px 0 ''${HOVER}px 0;
      }

      /* left end */
      button:hover#lock {
        margin: ''${HOVER}px 0 ''${HOVER}px ''${MARGIN}px;
      }

      #lock {
        border-radius: ''${BUTTON_RADIUS}px 0 0 ''${BUTTON_RADIUS}px;
        margin: ''${MARGIN}px 0 ''${MARGIN}px ''${MARGIN}px;
      }

      /* right end */
      button:hover#reboot {
        margin: ''${HOVER}px ''${MARGIN}px ''${HOVER}px 0;
      }

      #reboot {
        border-radius: 0 ''${BUTTON_RADIUS}px ''${BUTTON_RADIUS}px 0;
        margin: ''${MARGIN}px ''${MARGIN}px ''${MARGIN}px 0;
      }
    '';
  };
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 300;
        hide_cursor = true;
        no_fade_in = false;
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
          shadow_passes = 2;
        }
      ];
    };
  };
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };
      listener = [
        {
          timeout = 180;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
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
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.lxde.lxsession}/bin/lxpolkit";
      Restart = "always";
      RestartSec = 3;
    };
  };
  services.wlsunset = {
    enable = true;
    latitude = "39.3";
    longitude = "-76.6";
    systemdTarget = "hyprland-session.target";
  };
  xdg.configFile."keymap_backtick.xkb".source = ../keymap_backtick.xkb;
  services.network-manager-applet.enable = true;
  xsession.preferStatusNotifierItems = true;

  dconf = {
    enable = true;
    settings."org/freedesktop/appearance" = {
      color-scheme = 2;
    };
    settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-light";
    };
  };

  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        profile = {
          name = "home_office";
          outputs = [
            {
              criteria = "Technical Concepts Ltd 65R648 Unknown";
              mode = "7680x4320";
              position = "0,0";
              transform = "normal";
              status = "enable";
            }
          ];
        };
      }
    ];
  };
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      #hyprlandPortal
    ];
    configPackages = [ hyprlandPackage ];
  };
  systemd.user.services.plugged_in_suspend_inhibitor = {
    Service = {
      ExecStart = "systemd-inhibit sleep infinity";
      Restart = "always";
      RestartSec = 3;
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
          "hyprland/submap"
          "sway/workspaces"
          "hyprland/workspaces"
          "custom/right-blue-background"
        ];
        modules-center = [
          "sway/window"
          "hyprland/window"
        ];
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
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
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
        "hyprland/submap" = {
          format = "⚠️ <span style=\"italic\">{}</span>";
          tooltip = false;
        };
        "hyprland/window" = {
          format = "{}";
          max-length = 30;
          tooltip = false;
        };
        "hyprland/workspaces" = {
          all-outputs = false;
          disable-scroll = false;
          format = "{icon}";
          on-scroll-up = "${hyprlandPackage}/bin/hyprctl dispatch workspace e+1";
          on-scroll-down = "${hyprlandPackage}/bin/hyprctl dispatch workspace e-1";
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
            default = [
              "🔈"
              "🔉"
              "🔊"
            ];
          };
          on-click = "pavucontrol";
        };
        tray = {
          icon-size = 36;
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
          background: @base03;
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
          background: @base03;
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
          background: @base03;
      }
      #custom-right-cyan-background {
          font-size: 38px;
          color: @cyan;
          background: @base03;
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
          background: @base03;
      }
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
    '';
  };
  home.packages = with pkgs; [
    waybar
    lxde.lxsession
    grim
    slurp
    i2c-tools
    kanshi
    wl-clipboard
    xorg.xhost
    xdg-utils
    glib
    numix-solarized-gtk-theme
    networkmanagerapplet
    libnotify
  ];
}
