{ pkgs, inputs, ... }:
let
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

  fine-cmdline-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "fine-cmdline-nvim";
    src = inputs.fine-cmdline-nvim;
    meta = {
      homepage = "https://github.com/VonHeikemen/fine-cmdline.nvim";
      maintainers = [ "VonHeikemen" ];
    };
  };

  mcpServersConfig = pkgs.writeTextFile {
    name = "mcp-servers.json";
    text = builtins.toJSON {
      mcpServers = {
        Hub.url = "http://localhost:37373/mcp";
        filesystem = {
          command = "${pkgs.nodejs}/bin/npx";
          args = [
            "-y"
            "@modelcontextprotocol/server-filesystem"
            "/home/douglas/src/aip"
          ];
          autostart = true;
        };
        git = {
          command = "${pkgs.steam-run}/bin/steam-run";
          args = [
            "${pkgs.uv}/bin/uvx"
            "mcp-server-git"
            "--repository"
            "/home/douglas/src/aip"
          ];
          autostart = true;
        };
      };
    };
  };
in
{

  xdg.configFile."nvim/spell/en.utf-8.spl".source = inputs.nvim-spell-en-utf8-dictionary;
  xdg.configFile."nvim/spell/en.utf-8.sug".source = inputs.nvim-spell-en-utf8-suggestions;
  xdg.configFile."nvim/spell/en.ascii.spl".source = inputs.nvim-spell-en-ascii-dictionary;
  xdg.configFile."nvim/spell/en.ascii.sug".source = inputs.nvim-spell-en-ascii-suggestions;
  xdg.configFile."nvim/spell/en.latin1.spl".source = inputs.nvim-spell-en-latin1-dictionary;
  xdg.configFile."nvim/spell/en.latin1.sug".source = inputs.nvim-spell-en-latin1-suggestions;
  xdg.configFile."nvim/spell/fr.utf-8.spl".source = inputs.nvim-spell-fr-utf8-dictionary;
  xdg.configFile."nvim/spell/fr.utf-8.sug".source = inputs.nvim-spell-fr-utf8-suggestions;
  xdg.configFile."nvim/spell/fr.latin1.spl".source = inputs.nvim-spell-fr-latin1-dictionary;
  xdg.configFile."nvim/spell/fr.latin1.sug".source = inputs.nvim-spell-fr-latin1-suggestions;

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
    pyright

    # Javascript
    nodePackages.typescript-language-server

    # Go
    gopls

    # C++
    ccls

    # Rust
    rustfmt # dependency
    rustc # dependency
    cargo # dependency
    rust-analyzer

    # AI / MCP stuff
    inputs.mcp-hub.packages.${pkgs.system}.default
    nodejs
  ];

  home.file.".config/mcphub/servers.json".source = mcpServersConfig;

  programs.neovim = {
    enable = true;
    # withPython = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
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

      # Floating 'Ex' command window
      nui-nvim # Library dependency
      fine-cmdline-nvim

      #######################################################################
      # ****** UPDATED TEXT/COMMAND FEATURES ******
      #######################################################################

      # Code commenting
      comment-nvim

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

      # Tmux clipboard integration
      tmux-nvim

      #######################################################################
      # ****** UPDATED UI FEATURES ******
      #######################################################################

      # Explorer for Vim's tree-based undo history
      undotree

      # File explorer
      # NvimTree (faster NerdTree replacement)
      # nvim-tree-lua

      # Attempting to try neotree (avante integration)
      nui-nvim # Library dependency
      plenary-nvim # Library dependency
      nvim-window-picker # Optional library dependency
      nvim-web-devicons # Optional library dependency
      nvim-lsp-file-operations # Optional library dependencys
      neo-tree-nvim

      # Status bar with coloring
      lualine-nvim
      lualine-lsp-progress

      # Built-in debugger
      vimspector

      # Vim Git UI
      vim-fugitive
      gitsigns-nvim

      # Buffers as 'tabs'
      # nvim-web-devicons # Library ependency (above)
      bufferline-nvim

      # Configure fuzzy finder integration
      # plenary-nvim # Library dependency (above)
      telescope-nvim
      telescope-fzf-native-nvim

      #######################################################################
      # ****** FILETYPE SPECIFIC PLUGINS ******
      #######################################################################

      # Nix Filetype support
      vim-nix

      # Vim browser markdown preview
      #vim-markdown-composer

      # Better YAML support
      vim-yaml

      # Dart language support
      dart-vim-plugin

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
      outline-nvim

      # Two possible diagnostics displays
      trouble-nvim
      lsp_lines-nvim

      # AI Tools
      {
        plugin = avante-nvim;
        type = "lua";
        config = ''
          require("avante_lib").load()
          require("avante").setup({
            provider = "llamacpp",
            providers = {
              llamacpp = {
                __inherited_from = 'openai',
                endpoint = "http://localhost:8080/v1",
                api_key_name = "OPEN_API_KEY",
                model = "unused",
                disable_tools = false,
                stream = true,
                extra_request_body = {
                  temperature = 0.7,
                  max_tokens = 2048,
                },
              }
            },
            behaviour = {
              auto_suggestions = false, -- Experimental stage
              auto_set_highlight_group = true,
              auto_set_keymaps = true,
              auto_apply_diff_after_generation = false,
              support_paste_from_clipboard = false,
              minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
            },
            system_prompt = function()
              local hub = require("mcphub").get_hub_instance()
              if hub then
                return hub:get_active_servers_prompt()
              end
            end,
            custom_tools = function()
              return {
                require("mcphub.extensions.avante").mcp_tool(),
              }
            end,
          })
        '';
      }
      markview-nvim # Library dependency
      nui-nvim # Library dependency
      inputs.mcphub-nvim.packages.${pkgs.system}.default
      # codecompanion-nvim
    ];

    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
