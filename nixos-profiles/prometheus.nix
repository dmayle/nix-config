{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "grafana.serenity";
        http_port = 2342;
        htp_addr = "127.0.0.1";
      };
    };
  };
  services.prometheus = {
    enable = true;
    globalConfig.scrape_interval = "10s";
    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "logind"
          "systemd"
        ];
        disabledCollectors = [
          "textfile"
        ];
      };
      nvidia-gpu = {
        enable = true;
        port = 9101;
      };
    };
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = with config.services.prometheus.exporters; [
              "localhost:${toString node.port}"
              "localhost:${toString nvidia-gpu.port}"
            ];
          }
        ];
      }
    ];
  };
}
