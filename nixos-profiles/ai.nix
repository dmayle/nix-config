{ pkgs, inputs, ... }: {
  services.ollama = {
    enable = true;
    loadModels = [];
  };
}
