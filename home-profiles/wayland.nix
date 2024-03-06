{ config, pkgs, lib, ... }:
let
  # This is just a default background image for the lock screen
  bgNixSnowflake = builtins.fetchurl {
    url = "https://i.imgur.com/4Xqpx6R.png";
    sha256 = "bf0d77eceef6d85c62c94084f5450e2125afc4c8eed9f6f81298771e286408ac";
  };
in
{
  # Test hypridle / hyprlock config
  xdg.configFile."hypr/hypridle.conf" = {
    text = ''
      $lock_cmd = ${pkgs.procps}/bin/pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock

      general {
        lock_cmd = $lock_cmd
        before_sleep_cmd = $lock_cmd
      }

      listener {
        timeout = 180 # seconds (3 minutes)
        on-timeout = $lock_cmd
      }

      listener {
        timeout = 240 # seconds (4 minutes)
        on-timeout # ${pkgs.hyprland}/bin/hyprctl dispatch dpms off
        on-resume # ${pkgs.hyprland}/bin/hyprctl dispatch dpms on
      }
    '';
  };
  xdg.configFile."hypr/hyprlock.conf" = {
    text = ''
    '';
  };

  # Setup screensaver / lock with swayidle and swaylock
  # services.swayidle = {
  #   package = pkgs.hypridle
  #   enable = true;
  #   # events = [
  #   #   { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock -elfF -s fill -i ${bgNixSnowflake}"; }
  #   #   { event = "after-resume"; command = "${pkgs.hyprland}/bin/hyprctl 'output * enable' && ${pkgs.systemd}/bin/systemctl --user restart kanshi"; }
  #   #   { event = "lock"; command = "${pkgs.swaylock-effects}/bin/swaylock -elfF -s fill -i ${bgNixSnowflake}"; }
  #   # ];
  #   # timeouts = [
  #   #   { timeout = 600; command = "${pkgs.swaylock-effects}/bin/swaylock -elfF -s fill -i ${bgNixSnowflake}"; resumeCommand = "${pkgs.hyprland}/bin/hyprctl 'output * dpms on; && ${pkgs.systemd}/bin/systemctl --user restart kanshi"; }
  #   #   { timeout = 900; command = "${pkgs.hyprland}/bin/hyprctl 'output * dpms off'"; }
  #   # ];
  #   # extraArgs = [
  #   #   "idlehint 300"
  #   # ];
  #   systemdTarget = "hyprland-session.target";
  # };

  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "${pkgs.systemd}/bin/loginctl lock-session";
        text = "lock";
        keybind = "l";
      }
      {
        label = "logout";
        action = "${pkgs.hyprland}/bin/hyprctl dispatch exit";
        text = "logout";
        keybind = "l";
      }
      {
        label = "shutdown";
        action = "${pkgs.systemd}/bin/systemctl poweroff";
        text = "power_settings_new";
        keybind = "l";
      }
      {
        label = "reboot";
        action = "${pkgs.systemd}/bin/systemctl reboot";
        text = "restart_alt";
        keybind = "l";
      }
    ];
    style = ''
      * {
        all: unset;
        background-image: none;
        transition: 400ms cubic-bezier(0.05, 0.7, 0.1, 1);
      }

      window {
        background: rgba(0, 0, 0, 0.5);
      }

      button {
        font-family: 'Material Symbols Outlined';
        font-size: 10rem;
        background-color: rgba(11, 11, 11, 0.4);
        color: #FFFFFF;
        margin: 2rem;
        border-radius: 2rem;
        padding: 3rem;
      }

      button:focus,
      button:active,
      button:hover {
        background-color: rgba(51, 51, 51, 0.5);
        border-radius: 4rem;
      }
    '';
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
    latitude = "37.7";
    longitude = "-122.5";
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
      gtk-theme = "Adwaita";
    };
  };
  services.swayosd = {
    enable = true;
    topMargin = 0.5;
  };
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    profiles = {
      home_office = {
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
    };
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
      xdg-desktop-portal-hyprland
    ];
    configPackages = [ pkgs.hyprland ];
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
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      RestartSec = 5;
      Restart = "always";
    };
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
        modules-center = [ "sway/window" "hyprland/window" ];
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
          on-scroll-up = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e+1";
          on-scroll-down = "${pkgs.hyprland}/bin/hyprctl dispatch workspace e-1";
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
    gnome3.adwaita-icon-theme
    libadwaita
    networkmanagerapplet
  ];
}
