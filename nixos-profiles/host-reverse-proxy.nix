{ ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "dmayle@dmayle.com";
    # environmentFile = config.sops.secrets."acme/email".path;
  };
  services.nginx = {
    enable = true;
  };
  # Have ttyd listen on loopback and only expose it via this proxy
  services.ttyd.interface = "lo";
}
