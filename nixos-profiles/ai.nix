{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.llama-cpp = {
    enable = true;
    package = (pkgs.llama-cpp-vulkan.overrideAttrs (oldAttrs: rec {
      version = "6210";
      src = pkgs.fetchFromGitHub {
        owner = "ggml-org";
        repo = "llama.cpp";
        tag = "b${version}";
        hash = "sha256-yPlFw3fuXvf4+IhOv0nVI9hnuZq73Br6INn8wdOmCOs=";
        leaveDotGit = true;
        postFetch = ''
          git -C "$out" rev-parse --short HEAD > $out/COMMIT
          find "$out" -name .git -print0 | xargs -0 rm -rf
        '';
      };
    }));
    model
    = "/var/lib/llama-cpp/models/unsloth_Qwen3-Coder-30B-A3B-Instruct-GGUF_Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf";
    # host = "0.0.0.0";
    extraFlags = [
      "--jinja"
      "-ngl" "99"
      "--threads" "-1"
      "--ctx-size" "262144"
      "--temp" "0.7"
      "--min-p" "0.0"
      "--top-p" "0.80"
      "--top-k" "20"
      "--repeat-penalty" "1.05"
      "-ctv" "q4_0"
      "-ctk" "q4_0"
      "--flash-attn"
    ];
  };
  services.ollama = {
    enable = true;
    loadModels = [ ];
  };
  systemd.services.nix-daemon.serviceConfig.EnvironmentFile =
    config.sops.secrets."ai_tokens/hugging_face".path;
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
      "hyper-sd15-1step-lora"
      "ltx-video"
      "stable-diffusion-v1-5"
      "t5-v1_1-xxl-encoder"
      "t5xxl_fp16"
      "sams"
      "ultrarealistic-lora"
    ] pkgs.nixified-ai.models;
    customNodes = with pkgs.comfyuiPackages; [
      comfyui-gguf
      # comfyui-impact-pack
    ];
  };
}
