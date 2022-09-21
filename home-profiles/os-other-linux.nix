{ config, pkgs, inputs, ... }:
let
  nixgl = import <nixgl> {};
in
{
  # Tree-sitter parsers for languages
  home.file."${config.xdg.configHome}/nvim/parser/bash.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-bash}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/c.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-c}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/cpp.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-cpp}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/dart.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-dart}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/go.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-go}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/html.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-html}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/java.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-java}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/javascript.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-javascript}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/lua.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-lua}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/markdown.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-markdown}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/nix.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-nix}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/python.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-python}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/vim.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-vim}/parser";

  systemd.user.sessionVariables = {
    LD_PRELOAD = "/usr/lib/x86_64-linux-gnu/libnss_cache.so.2";
  };

  targets.genericLinux.enable = true;

  home.packages = with pkgs; with inputs; [
    # List of packages that we inherit from gLinux instead of installing
    # git # Has custom protocol

    # Non-Google3 Language servers
    rnix-lsp                          # .nix files
    nodePackages.vim-language-server  # .vim files
    nodePackages.bash-language-server # .sh files

    nixgl.nixGLIntel
  ];
}
