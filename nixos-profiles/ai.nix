{ pkgs, inputs, ... }: {
  services.ollama = {
    enable = true;
    loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"
    "hf.co/unsloth/gemma-3-27b-it-GGUF:Q4_K_M" ];
  };
}
