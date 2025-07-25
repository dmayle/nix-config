{ lib, pkgs, ... }:
{
  services.ollama = {
    enable = true;
    loadModels = [ ];
  };
  services.comfyui = {
    enable = true;
    acceleration = "cuda";
    # package = pkgs.comfyui;
    host = "127.0.0.1";
    # models = builtins.attrValues pkgs.nixified-ai.models;
    models = lib.attrsets.attrVals [
      # Commented models are gated and require special tokens to access
      # "christmas-couture-lora"
      # "flux-ae"
      # "flux-text-encoder-1"
      # "flux1-dev-q4_0"
      # "hyper-sd15-1step-lora"
      # "ltx-video"
      # "stable-diffusion-v1-5"
      # "t5-v1_1-xxl-encoder"
      # "t5xxl_fp16"
      "sams"
      "ultrarealistic-lora"
    ] pkgs.nixified-ai.models;
    customNodes = with pkgs.comfyuiPackages; [
      comfyui-gguf
      # comfyui-impact-pack
    ];
  };
}
