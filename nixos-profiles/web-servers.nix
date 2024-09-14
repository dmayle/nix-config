{ config, pkgs, ... }: {
  # TODO
  # * Fix color of default terminal
  # * Fix font so that nvim_tree icons work
  # * Fix font so that it uses font I like
  security.acme = {
    acceptTerms = true;
    defaults.email = "dmayle@dmayle.com";
    defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
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
  };
}
