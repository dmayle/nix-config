{ pkgs, inputs, ... }:
let
  # Custom neovim plugins
  vim-maximizer = pkgs.vimUtils.buildVimPlugin {
    name = "vim-maximizer";
    src = inputs.vim-maximizer;
    meta = {
      homepage = "https://github.com/szw/vim-maximizer";
      maintainers = [ "szw" ];
    };
  };

  vim-fakeclip = pkgs.vimUtils.buildVimPlugin {
    name = "vim-fakeclip";
    src = inputs.vim-fakeclip;
    meta = {
      homepage = "https://github.com/kana/vim-fakeclip";
      maintainers = [ "kana" ];
    };
  };

  NeoSolarized-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "NeoSolarized-nvim";
    src = inputs.NeoSolarized-nvim;
    meta = {
      homepage = "https://github.com/Tsuzat/NeoSolarized.nvim";
      maintainers = [ "tsuzat" ];
    };
  };

  nvim-spell-en-utf8-dictionary = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/en.utf-8.spl";
    sha256 = "fecabdc949b6a39d32c0899fa2545eab25e63f2ed0a33c4ad1511426384d3070";
  };

  nvim-spell-en-utf8-suggestions = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/en.utf-8.sug";
    sha256 = "5b6e5e6165582d2fd7a1bfa41fbce8242c72476222c55d17c2aa2ba933c932ec";
  };

  nvim-spell-en-ascii-dictionary = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/en.ascii.spl";
    sha256 = "cebcba489d45da3355940f340582e20ce35ecdcd44f9cc168be873f08e782449";
  };

  nvim-spell-en-ascii-suggestions = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/en.ascii.sug";
    sha256 = "b0d5d0ed19735f837248ef97bccb444ad730340b1785c8f6a8e4458f6872216c";
  };

  nvim-spell-en-latin1-dictionary = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/en.latin1.spl";
    sha256 = "620d9efcd79cfc9d639818fb52807e3dae61a37c800d694a010cd525a2161845";
  };

  nvim-spell-en-latin1-suggestions = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/en.latin1.sug";
    sha256 = "e6de97e4bcb3f9b4aaf7e1eb54a81b9390d5c231f427fa4be3798a25e4622b02";
  };

  nvim-spell-fr-utf8-dictionary = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/fr.utf-8.spl";
    sha256 = "abfb9702b98d887c175ace58f1ab39733dc08d03b674d914f56344ef86e63b61";
  };

  nvim-spell-fr-utf8-suggestions = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/fr.utf-8.sug";
    sha256 = "0294bc32b42c90bbb286a89e23ca3773b7ef50eff1ab523b1513d6a25c6b3f58";
  };

  nvim-spell-fr-latin1-dictionary = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/fr.latin1.spl";
    sha256 = "086ccda0891594c93eab143aa83ffbbd25d013c1b82866bbb48bb1cb788cc2ff";
  };

  nvim-spell-fr-latin1-suggestions = builtins.fetchurl {
    url = "http://ftp.vim.org/vim/runtime/spell/fr.latin1.sug";
    sha256 = "5cb2c97901b9ca81bf765532099c0329e2223c139baa764058822debd2e0d22a";
  };
in
{

  xdg.configFile."nvim/spell/en.utf-8.spl".source = nvim-spell-en-utf8-dictionary;
  xdg.configFile."nvim/spell/en.utf-8.sug".source = nvim-spell-en-utf8-suggestions;
  xdg.configFile."nvim/spell/en.ascii.spl".source = nvim-spell-en-ascii-dictionary;
  xdg.configFile."nvim/spell/en.ascii.sug".source = nvim-spell-en-ascii-suggestions;
  xdg.configFile."nvim/spell/en.latin1.spl".source = nvim-spell-en-latin1-dictionary;
  xdg.configFile."nvim/spell/en.latin1.sug".source = nvim-spell-en-latin1-suggestions;
  xdg.configFile."nvim/spell/fr.utf-8.spl".source = nvim-spell-fr-utf8-dictionary;
  xdg.configFile."nvim/spell/fr.utf-8.sug".source = nvim-spell-fr-utf8-suggestions;
  xdg.configFile."nvim/spell/fr.latin1.spl".source = nvim-spell-fr-latin1-dictionary;
  xdg.configFile."nvim/spell/fr.latin1.sug".source = nvim-spell-fr-latin1-suggestions;

  # LSP language servers I use
  home.packages = with pkgs; [
    # Lua
    lua-language-server

    # Nix
    nil

    # YAML
    nodePackages.yaml-language-server

    # Bash
    nodePackages.bash-language-server

    # Python
    nodePackages.pyright

    # Go
    gopls

    # C++
    ccls
  ];

  programs.neovim = {
    enable = true;
    # withPython = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      #######################################################################
      # ****** BASIC TOOLING ******
      #######################################################################

      # Plugin libraries
      vim-maktaba

      #######################################################################
      # ****** ENHANCE EXISTING FUNCTIONALITY ******
      #######################################################################

      # Make % command (jump to matching pair) work better
      matchit-zip

      # Make . command (repeat) work better
      vim-repeat

      # Ensure quotes and brackets are added together
      nvim-autopairs

      # Allow number increment (Ctrl-A, Ctrl-X) to work for dates
      vim-speeddating

      # Additional copy/paste buffer '&' for tmux
      vim-fakeclip

      # Start using treesitter
      nvim-treesitter.withAllGrammars

      # Ensure increment operator (Ctrl-A, Ctrl-X) works in visual/block mode
      vim-visual-increment

      # Live search/replace preview
      vim-over

      #######################################################################
      # ****** LOOK AND FEEL ******
      #######################################################################

      # solarized
      NeoSolarized-nvim

      # Configurable text colorizing
      nvim-colorizer-lua

      # Both Indent guides plugins
      indent-blankline-nvim

      #######################################################################
      # ****** UPDATED TEXT/COMMAND FEATURES ******
      #######################################################################

      # Code commenting
      vim-commentary

      # Toggle between maximizing current split, and then restoring previous
      # split state
      vim-maximizer

      # Tools for working with doxygen comments
      DoxygenToolkit-vim

      # For converting camelCase to snake_case mostly
      vim-abolish

      # Delete, update, insert quotes, brackets, tags, parentheses, etc.
      vim-surround

      # Bracket mappings mostly for navigation
      vim-unimpaired

      # Add text object for indentation level (mostly for python)
      vim-indent-object

      # Add bracket mappings for diff conflict markers ]x [x
      conflict-marker-vim

      #######################################################################
      # ****** UPDATED UI FEATURES ******
      #######################################################################

      # Explorer for Vim's tree-based undo history
      undotree

      # File explorer
      # NvimTree (faster NerdTree replacement)
      nvim-tree-lua

      # Source code class explorer
      aerial-nvim

      # Status bar with coloring
      lualine-nvim
      lualine-lsp-progress

      # Built-in debugger
      vimspector

      # Vim Git UI
      vim-fugitive
      gitsigns-nvim

      # Configure fuzzy finder integration
      plenary-nvim # Library dependency
      telescope-nvim
      telescope-fzf-native-nvim

      #######################################################################
      # ****** FILETYPE SPECIFIC PLUGINS ******
      #######################################################################

      # Nix Filetype support
      vim-nix

      # Vim browser markdown preview
      vim-markdown-composer

      # Better YAML support
      vim-yaml

      # Dart language support
      dart-vim-plugin

      # Working on introducing
      trouble-nvim

      # Stupid, but I want to delete a buffer without losing window state
      bufdelete-nvim

      # bazel build file support
      vim-bazel

      #######################################################################
      # ****** CODE ENHANCEMENT ******
      #######################################################################

      # Builtin Nvim LSP support
      nvim-lspconfig

      # Lightweight autocompletion
      luasnip
      friendly-snippets
      nvim-cmp
      cmp_luasnip
      cmp-nvim-lsp
      cmp-nvim-lua
      cmp-vim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-treesitter
      cmp-tmux
      cmp-spell
      lsp-format-nvim
      lspkind-nvim

      # Highlight code symbol under cursor
      vim-illuminate

      # Create a code structure explorer based on LSP
      vista-vim
    ];

    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
