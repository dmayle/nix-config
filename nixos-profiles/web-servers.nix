{ config, pkgs, ... }: {
  # TODO
  # * Fix color of default terminal
  # * Fix font so that nvim_tree icons work
  # * Fix font so that it uses font I like
  # * Encrypt config
  security.acme = {
    acceptTerms = true;
    defaults.email = "dmayle@dmayle.com";
  };
  services.nginx = {
    enable = true;
    virtualHosts = {
      "fox.mayle.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:7681/";
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
  disabledModules = [ "services/web-servers/ttyd.nix" ];
  imports = [ ./ttyd.nix ];
  services.ttyd = {
    enable = true;
    # for client cert verification:
    # caFile = ./foo;
    # enableSSL = true;
    checkOrigin = true;
    writeable = true;
    passwordFile = config.sops.secrets."ttyd/password".path;
    clientOptions = {
      # /* Solarized */
      # @define-color base03 #002b36;
      # @define-color base02 #073642;
      # @define-color base01 #586e75;
      # @define-color base00 #657b83;
      # @define-color base0 #839496;
      # @define-color base1 #93a1a1;
      # @define-color base2 #eee8d5;
      # @define-color base3 #fdf6e3;
      # @define-color yellow #b58900;
      # @define-color orange #cb4b16;
      # @define-color red #dc322f;
      # @define-color magenta #d33682;
      # @define-color violet #6c71c4;
      # @define-color blue #268bd2;
      # @define-color cyan #2aa198;
      # @define-color green #859900;
      # selectionInactiveBackground = "";
      # cursorAccent = "";


      # Solarized Theme
      theme = "{\"background\":\"#fdf6e3\",\"foreground\":\"#657b83\",\"cursor\":\"#586e75\",\"selectionBackground\":\"#586e75\",\"selectionForeground\":\"#eae3cb\",\"black\":\"#073642\",\"brightBlack\":\"#002b36\",\"red\":\"#dc322f\",\"brightRed\":\"#cb4b16\",\"green\":\"#859900\",\"brightGreen\":\"#586e75\",\"yellow\":\"#b58900\",\"brightYellow\":\"#657b83\",\"blue\":\"#268bd2\",\"brightBlue\":\"#839496\",\"magenta\":\"#d33682\",\"brightMagenta\":\"#6c71c4\",\"cyan\":\"#2aa198\",\"brightCyan\":\"#93a1a1\",\"white\":\"#eee8d5\",\"brightWhite\":\"#fdf6e3\"}";
    };
  };
}
