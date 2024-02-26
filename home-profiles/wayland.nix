{ config, pkgs, lib, ... }:

{
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
  ];
}
