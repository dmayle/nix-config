{
  pkgs,
  modulesPath,
  config,
  inputs,
  lib,
  ...
}:

{
  imports = with inputs.self; [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    inputs.self.nixosRoles.base
    nixosProfiles.ai
    nixosProfiles.docker
    nixosProfiles.web-servers
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # Preload AI models specific to this machine
  services.ollama.loadModels = [
    "qwen3:14b-q4_K_M"
  ];

  # Setup the machine name
  networking.hostName = "fox";

  # Set your time zone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Basic console configuration supporting latin languages
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "gb";
    options = "caps:swapescape";
    variant = "extd";
    model = "pc105";
  };
  services.libinput.enable = true;

  # TODO: move this to desktop profile
  # This is a desktop machine we don't want turning off so that we can access
  # it from the network
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  users.users.douglas = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
    ];
    hashedPasswordFile = config.sops.secrets."users/douglas".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAgeON0VkK4mu9XOalV1Alp5vFztuhT8T/g75JpJjFwe douglas@beast"
    ];
  };
  nix.settings.allowed-users = [ "@wheel" ];

  # Setup sops
  sops = {
    defaultSopsFile = ../../secrets/fox.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      "acme/email" = { };
      "ttyd/username" = { };
      "ttyd/password" = { };
      "users/douglas".neededForUsers = true;
    };
  };

  # Some basic packages I want available if I use the system as root
  environment.systemPackages = with pkgs; [
    curl
    wget
    git
    file
  ];

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
}
