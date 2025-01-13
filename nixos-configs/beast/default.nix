{ pkgs, config, inputs, lib, ... }:

{
  imports = with inputs.self; [
    ./hardware-configuration.nix
    inputs.self.nixosRoles.desktop
    inputs.self.nixosProfiles.docker
    inputs.self.nixosProfiles.virtualbox
    inputs.self.nixosProfiles.sound
    inputs.self.nixosProfiles.games
    inputs.self.nixosProfiles.cachix-cuda
    inputs.self.nixosProfiles.cachix-nixpkgs-wayland
    #inputs.self.nixosProfiles.web-servers
    ./acme-default.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Add NTFS support
  boot.supportedFilesystems = [ "ntfs" ];

  # Setup the machine name
  networking.hostName = "beast";

  # Set your time zone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Basic console configuration supporting latin languages
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Setup the hardware to use nvidia drivers, and ensure hardware acceleration
  # support for wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    modesetting.enable = true;
    nvidiaSettings = true;
    open = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
      vulkan-validation-layers
      mesa.drivers
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
      vulkan-validation-layers
      mesa.drivers
    ];
  };

  # Nvidia fixup
  services.xserver.deviceSection = ''
    Option "SidebandSocketPath" "/tmp"
  '';

  # Trying out Prometheus and Grafana for desktop monitoring
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "home.mayle.org";
      };
    };
  };


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    options = "caps:swapescape";
    variant = "extd";
    model = "pc105";
  };
  services.libinput.enable = true;
  services.xserver.enable = true;

  services.xserver.resolutions = [{ x = 7680; y = 4320; }];
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false;
  };

  # We enable desktop managers in order to setup a graphical login with gnome
  # and hyprland. We want those to be configured by home-manager, so we'll have
  # to fixup this config a bit
  services.xserver.desktopManager.gnome.enable = true;
  # This adds a hyprland session to gdm, but the session just selects hyprland
  # from the current environment. My home manager config will override that
  # version, so all config should be done there.
  programs.xwayland.enable = true;
  programs.hyprland.enable = true;

  # Enabling desktop managers forces xdg-desktop-portal (services for sandboxed
  # applications) to be configured. We want to configure this at the
  # home-manager level, so we forcibly disable it here.
  xdg.portal.enable = lib.mkForce false;

  # TODO: move this to desktop profile
  # This is a desktop machine we don't want turning off so that we can access
  # it from the network
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  users.users.douglas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "sway" "video" "i2c" "docker" "vboxusers" ];
  };
  nix.settings.allowed-users = [ "@wheel" ];

  # Some basic packages I want available if I use the system as root
  environment.systemPackages = with pkgs; [
    xorg.libpciaccess
    wget
    git
    file
    canon-cups-ufr2
    gnomeExtensions.gtile
    # Adds udev rules for access to QMK keyboards
    via
  ];

  # Allow via (and http://usevia.app) to access hidraw devices for updating/flashing
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Allow swaylock configured in home-manager to work.
  security.pam.services.swaylock = {};

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];

  # Very basic neovim config for root because vanilla vim is frustrating when
  # unconfigured
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  environment.variables.EDITOR = "nvim";
  environment.etc.inputrc.text = lib.mkAfter ''
    set editing-mode vi
    set keymap vi
  '';

  # Ensure that nix-* (e.g. nix-shell) use the same nixpkgs as this flake
  environment.etc."nixpath/nixpkgs".source = inputs.nixpkgs;
  nix.nixPath = [
    "nixpkgs=/etc/nixpath/nixpkgs"
  ];

  # Enable remote access
  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };

  # Prefer the network firewall
  networking.firewall.enable = false;

  system.stateVersion = "22.05"; # Did you read the comment?

  disabledModules = [ "security/acme/default.nix" "security/acme" ];
  security.acme = {
    acceptTerms = true;
    certs."beast.home.mayle.org" = {
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.secrets."acme/cloudflare".path;
      domain = "beast.home.mayle.org";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "beast.home.mayle.org" = {
        forceSSL = true;
        enableACME = true;
        acmeRoot = null; # Use the DNS-01 certificate from security.acme
        locations."/" = {
          proxyPass = "http://localhost:4000/";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };
  };

  # Setup sops
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets = {
      "acme/cloudflare" = {};
    };
  };
}
