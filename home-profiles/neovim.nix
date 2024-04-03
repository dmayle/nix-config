{ config, pkgs, inputs, ... }:
let
  # Custom neovim plugins
  vim-maximizer = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-maximizer";
    src = inputs.vim-maximizer;
    meta = {
      homepage = https://github.com/szw/vim-maximizer;
      maintainers = [ "szw" ];
    };
  };

  vim-glaive = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-glaive";
    src = inputs.vim-glaive;
    meta = {
      homepage = https://github.com/google/vim-glaive;
      maintainers = [ "google" ];
    };
  };

  vim-syncopate = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-syncopate";
    src = inputs.vim-syncopate;
    meta = {
      homepage = https://github.com/google/vim-syncopate;
      maintainers = [ "google" ];
    };
  };

  vim-fakeclip = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-fakeclip";
    src = inputs.vim-fakeclip;
    meta = {
      homepage = https://github.com/kana/vim-fakeclip;
      maintainers = [ "kana" ];
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
    lua-language-server
    nil
    nodePackages.yaml-language-server
    nodePackages.vim-language-server
    nodePackages.bash-language-server
    nodePackages.pyright
    gopls
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
      vim-glaive

      #######################################################################
      # ****** ENHANCE EXISTING FUNCTIONALITY ******
      #######################################################################

      # Make % command (jump to matching pair) work better
      matchit-zip

      # Make . command (repeat) work better
      vim-repeat

      # Ensure quotes and brackets are added together
      auto-pairs

      # Allow number increment (Ctrl-A, Ctrl-X) to work for dates
      vim-speeddating

      # Additional copy/paste buffer '&' for tmux
      vim-fakeclip

      # Start using treesitter
      nvim-treesitter

      # Ensure increment operator (Ctrl-A, Ctrl-X) works in visual/block mode
      vim-visual-increment

      # Live search/replace preview
      vim-over

      #######################################################################
      # ****** LOOK AND FEEL ******
      #######################################################################

      # solarized
      NeoSolarized

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

      # Simple buf list/navigate
      bufexplorer

      # Source code class explorer
      aerial-nvim

      # Status bar with coloring
      lualine-nvim
      lualine-lsp-progress

      # Built-in debugger
      vimspector

      # Vim Git UI
      vim-fugitive
      vim-signify

      # Configure fuzzy finder integration
      fzf-vim

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
      # vim-pyenv (depends on environments)
      # Rename (maybe replaced by NvimTree rename)

      # bazel build file support
      vim-bazel

      #######################################################################
      # ****** CODE ENHANCEMENT ******
      #######################################################################

      # Autoformatting plugin (to someday be replaced with LSP formatter)
      # https://www.reddit.com/r/neovim/comments/jvisg5/lets_talk_formatting_again/
      vim-codefmt

      # Builtin Nvim LSP support
      nvim-lspconfig

      # Lightweight autocompletion
      luasnip
      nvim-cmp
      cmp_luasnip
      cmp-vim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-treesitter
      cmp-tmux
      cmp-spell
      #completion-nvim
    ];

    extraLuaConfig = ''
      -- -----------------------------------------------------------------------
      -- LOCAL NAMESPACE VARIABLES
      -- -----------------------------------------------------------------------
      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd
      local keymap = vim.api.nvim_set_keymap
      -- Accessor for libuv
      local uv = vim.loop

      -- We put hostname into these paths so that a home directory which is on
      -- top of NFS and shared across hosts will not have conflicts
      local host = uv.os_gethostname()
      local homedir = os.getenv("HOME")
      local backupdir = string.format("%s/.vimbak-$s", homedir, host)
      local undodir = string.format("%s/.vimundo-$s", homedir, host)

      -- -----------------------------------------------------------------------
      -- GLOBAL SETTINGS
      -- -----------------------------------------------------------------------

      -- Disable builtin netrw
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- Default to bash support in shell scripts
      vim.g.is_bash = 1

      -- Lua table of options which will be set directly into vim options
      local options = {
        -- ---------------------------------------------------------------------
        -- OVERALL SETTINGS
        -- ---------------------------------------------------------------------

        -- I don't want files overriding my settings
        modelines = 0,

        -- I don't like beeping
        visualbell = true,

        -- Enable 24-bit color support
        termguicolors = true,

        -- We want to use Solarized light, but setting colorscheme is not an
        -- option, so that comes later
        background = "light",

        -- Always show available completion options, but selection must be
        -- manual
        completeopt = { "menuone", "noinsert", "noselect", "longest" },

        -- Default to case insensitive searching
        ignorecase = true,

        -- Unless I use case in my search string, then case matters
        smartcase = true,

        -- I like to be able to occasionally use the mouse
        mouse = "a",

        -- My status bar shows vim modes
        showmode = false,

        -- Trying out an always on tabline
        showtabline = 2,

        -- Have splits appear "after" current buffer
        splitright = true,
        splitbelow = true,

        -- Allow more-responsive async code (fire event 0.1s after typing stops)
        updatetime = 100,

        -- Trigger multi-key sequence 0.3s after typing stops
        -- (instead of waiting for additional keys, defaults to 1s)
        timeoutlen = 300,

        -- Default to showing the current line (useful for long terminals)
        cursorline = true,

        -- Make sure there is always at least 3 lines of context on either side
        -- of the cursor (above and below).
        scrolloff = 3,

        -- ---------------------------------------------------------------------
        -- Filetype setting defaults below, overridden per-language
        -- ---------------------------------------------------------------------

        -- Indentation defaults, overridden per-language
        autoindent = true,
        cindent = false,
        smartindent = false,

        -- Unless I'm in go or a makefile, I never want tabs
        expandtab = true,

        -- Two spaces is reasonable for indent levels by default
        tabstop = 2, -- treat tab characters as 2 spaces (rare, expandtab above)
        shiftwidth  = 2, -- increase and decrease 2 spaces with tab key

        -- Visual reminders of file width
        colorcolumn = { "+1", "+21", "+41" },

        -- Make tabs insert 'indents' when used at the beginning of the line
        smarttab = true,

        -- Keep unsaved files open with ther changes, even when switching buffers
        hidden = true,

        -- Show the length of the visual selection while making it
        showcmd = true,

        -- I speak english and french, but only turn on for certain filetypes
        spelllang = { "en_us", "fr" },

        -- Make backspace more powerful
        backspace = { "indent", "eol", "start" },

        -- I find it useful to have lots of command history
        history = 1000,

        -- When joining lines, don't insert unnecessary whitespace
        joinspaces = false,

        -- Save the current undo state between launches
        undofile = true,
        undolevels = 1000,
        undoreload = 10000,

        -- Set directory for swap files
        directory = backupdir,

        -- Set directory for undo files
        undodir = undodir,

        -- Set directory for backup files
        backupdir = backupdir,

        -- Set to only keep one (current) backup
        backup = true,
        writebackup = true,

        -- Sensible list of files we don't want backed up
        backupskip = '/tmp/*,/private/tmp/*,/var/tmp/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*',
      }

      for k, v in pairs(options) do
        vim.opt[k] = v
      end

      -- -----------------------------------------------------------------------
      -- MODIFY DEFAULT SETTINGS
      -- -----------------------------------------------------------------------

      -- Don't show useless match messages while matching
      vim.opt.shortmess:append "c"

      -- Have vim treat hyphen as part of character for word commands like "*"
      vim.opt.iskeyword:append "-"

      -- These are my format options, use :help fo-table to understand
      vim.opt.formatoptions:append 'rcoqnl1j'

      -- I prefer my diffs vertical for side-by-side comparison
      vim.opt.diffopt:append "vertical"

      -- -----------------------------------------------------------------------
      -- SET COLORSCHEME
      -- -----------------------------------------------------------------------

      -- Setting colorscheme is not an option, it's a call that needs to be
      -- made into vim. Normally I should check the return value here, but
      -- I don't know what I would do if it fails...
      pcall(vim.cmd, "colorscheme NeoSolarized")

      -- -----------------------------------------------------------------------
      -- MKDIRP: UTILITY FOR RECURSIVE DIRECTORY CREATION
      -- -----------------------------------------------------------------------

      local isWindows
      if _G.jit then
        isWindows = _G.jit.os == "Windows"
      else
        isWindows = not not package.path:match("\\")
      end

      function dirparent(dir)
        local sep
        if isWindows then
          sep = "\\"
        else
          sep = "/"
        end
        if not dir then
          return sep
        end
        result, _ = string.gsub(dir, string.format("%s[^%s]*$", sep, sep), "")
        return result
      end

      function mkdirp(path, mode, callback)
        uv.fs_stat(backupdir, function(err, stat)
          if not err then
            if stat.type ~= "directory" then
              err = string.format("Cannot create %s: File exists")
              callback(err, nil)
              return
            end
            -- Success!
            callback(nil, true)
            return
          end
          uv.fs_mkdir(path, mode, function(err, success)
            if success or string.match(err, "^EEXIST:") then
              -- Worked, or created during race, success!
              callback(nil, true)
              return
            end
            if string.match(err, "^ENOENT:") then
              -- The containing directory (which mkdir uses) does not exist
              mkdirp(dirparent(path), mode, function(err, success)
                if success then
                  -- Replay original dir creation once only
                  uv.fs_mkdir(path, mode, function(err, success)
                    if success or string.match(err, "^EEXIST:") then
                      -- Worked, or created during race, success!
                      callback(nil, true)
                      return
                    end
                    -- Propagate any mkdir error
                    callback(err, nil)
                  end)
                  return
                end
                -- Propagate error from creating parent directory
                callback(err, nil)
              end)
              return
            end
            -- Propagate unknown mkdir error
            callback(err, nil)
          end)
        end)
      end

      -- -----------------------------------------------------------------------
      -- CREATE NECESSARY BACKUP/UNDO DIRECTORIES
      -- -----------------------------------------------------------------------

      mkdirp(backupdir, 448, function(err, success)
        if not success then
          print(string.format("Error creating backup directory: %s", err))
        end
      end)

      mkdirp(undodir, 448, function(err, success)
        if not success then
          print(string.format("Error creating undo directory: %s", err))
        end
      end)

      -- -----------------------------------------------------------------------
      -- LOAD PLUGINS
      -- -----------------------------------------------------------------------

      require('nvim-tree').setup({
        filters = {
          custom = { '.git', '^bazel-.*$' }
        }
      })

      require('colorizer').setup()
      require('colorizer').attach_to_buffer(0)

      -- -----------------------------------------------------------------------
      -- AUTOCOMMAND GROUPS
      -- -----------------------------------------------------------------------
      local clear = { clear = true }
      local visualchars = augroup('VisualChars', clear)
      local filesettings = augroup('FileSettings', clear)
      local codefmtsettings = augroup('codefmtsettings', clear)
      local linenumbers = augroup('LineNumbers', clear)
      local lspconfiggroup = augroup('LSPConfig', clear)

      -- -----------------------------------------------------------------------
      -- AUTOCOMMANDS
      -- -----------------------------------------------------------------------
      -- VISUAL CHARACTERS
      -- -----------------------------------------------------------------------

      autocmd({ 'FileType' }, {
        desc = "Use visual characters to show tab and trailing whitespace",
        group = visualchars,
        callback = function()
          vim.opt.listchars = { tab = "▸ ", trail = "☐" }
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Use visual characters specific to go language",
        group = visualchars,
        pattern = "go",
        callback = function()
          vim.opt.listchars = { tab = "| ", trail = "☐" }
        end,
      })

      -- Make sure that trailing whitespace is Red
      vim.cmd([[match errorMsg /\s\+$/]])

      -- -----------------------------------------------------------------------
      -- FILETYPE SETTINGS
      -- -----------------------------------------------------------------------

      autocmd({ 'FileType' }, {
        desc = "Set up default spacing and tabs for a few filetypes.  I've \z
                left off Go, since the filetype plugin handles it for me.",
        group = filesettings,
        pattern = { "mail", "text", "python", "gitcommit", "c", "cpp", "java",
                    "sh", "vim", "puppet", "xml", "json", "javascript", "html",
                    "yaml", "dart" },
        callback = function()
          vim.opt_local.tabstop = 8
          vim.opt_local.shiftwidth = 2
          vim.opt_local.expandtab = true
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Turn on spellchecking for some filetypes",
        group = filesettings,
        pattern = { "mail", "text", "python", "gitcommit", "c", "cpp" },
        callback = function()
          vim.opt_local.spell = true
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Use 80-column lines for some file types",
        group = filesettings,
        pattern = { "mail", "text", "vim", "c", "cpp", "nix" },
        callback = function()
          vim.opt_local.textwidth = 80
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Fix the comment handling, which is set to c-style by default",
        group = filesettings,
        pattern = "puppet",
        callback = function()
          vim.opt_local.commentstring = "# %s"
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Standard GO tab settings (tabs, not spaces)",
        group = filesettings,
        pattern = "go",
        callback = function()
          vim.opt_local.tabstop = 4
          vim.opt_local.tabstop = 4
          vim.opt_local.expandtab = false
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Help files are both text and help, triggering spellchecking, \z
                so we manually disable it for them",
        group = filesettings,
        pattern = "help",
        callback = function()
          vim.opt_local.spell = false
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Don't hide markdown punctuation",
        group = filesettings,
        pattern = "markdown",
        callback = function()
          vim.opt_local.conceallevel = 0
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Teach vim-commentary about nasm comments",
        group = filesettings,
        pattern = "asm",
        callback = function()
          vim.opt_local.commentstring = "; %s"
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Ensure that we autowrap git commits to 72 characters, per \z
                tpope's guidelines for good git comments.",
        group = filesettings,
        pattern = "gitcommit",
        callback = function()
          vim.opt_local.textwidth = 72
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "I use 100-column lines in Java files",
        group = filesettings,
        pattern = "java",
        callback = function()
          vim.opt_local.textwidth = 100
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Change line continuation rules for Java. j1 is for Java \z
                anonymous classes, +2s says indent 2xshiftwidth on line \z
                continuations.",
        group = filesettings,
        pattern = "java",
        callback = function()
          vim.opt_local.cinoptions = "j1,+2s"
        end,
      })

      -- -----------------------------------------------------------------------
      -- CODEFORMAT SETTINGS (CURRENTLY UNUSED)
      -- -----------------------------------------------------------------------

      autocmd({ 'VimEnter' }, {
        desc = "Activate Glaive",
        group = codefmtsettings,
        callback = function()
          vim.cmd('Glaive codefmt plugin[mappings]')
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = "bzl",
        callback = function() vim.cmd('AutoFormatBuffer buildifier') end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = { "c", "cpp", "proto", "javascript", "arduino" },
        callback = function() vim.cmd('AutoFormatBuffer clang-format') end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = "dart",
        callback = function() vim.cmd('AutoFormatBuffer dartfmt') end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = "go",
        callback = function() vim.cmd('AutoFormatBuffer gofmt') end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = { "html", "css", "sass", "scss", "less", "json" },
        callback = function() vim.cmd('AutoFormatBuffer js-beautify') end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = "java",
        callback = function()
          vim.cmd('AutoFormatBuffer google-java-format')
        end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = "python",
        callback = function() vim.cmd('AutoFormatBuffer yapf') end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = "rust",
        callback = function() vim.cmd('AutoFormatBuffer rustfmt') end,
      })

      autocmd({ 'FileType' }, {
        desc = "Configure codeformat for bazel build files",
        group = codefmtsettings,
        pattern = "vue",
        callback = function() vim.cmd('AutoFormatBuffer prettier') end,
      })

      -- -----------------------------------------------------------------------
      -- PLUGIN SETTINGS
      -- -----------------------------------------------------------------------
      -- LUALINE CONFIG
      -- -----------------------------------------------------------------------

      require('lualine').setup {
        options = {
          theme = 'solarized_light',
          --ignore_focus = { 'NvimTree' },
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename', 'lsp_progress'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'},
        },
        extensions = {
          'fzf', 'fugitive', 'man', 'nvim-tree',
        },
      }

      -- -----------------------------------------------------------------------
      -- INDENT BLANKLINE CONFIG
      -- -----------------------------------------------------------------------

      vim.g.indent_blankline_use_treesitter = true

      require('ibl').setup()

      -- -----------------------------------------------------------------------
      -- KEY MAPPINGS
      -- -----------------------------------------------------------------------

      local opts = { noremap = true, silent = true }

      -- Make Y mirror y, working like D and C, yank to the end of the line
      keymap("n", "Y", "y$", opts)

      -- Add an insert mode mapping to reflow the current line.
      keymap("i", "<C-G>q", "<C-O>gqq<C-O>A", opts)

      -- -----------------------------------------------------------------------
      -- PERSONAL SHORTCUTS (LEADER)
      -- -----------------------------------------------------------------------

      keymap("", "<Space>", "<Nop>", opts)
      vim.g.mapleader = ' '
      vim.g.maplocalleader = ' '

      -- Searches
      keymap("n", "<leader><space>", ":GFiles<CR>", opts)
      keymap("n", "<leader>ff", ":Rg<CR>", opts)
      -- inoremap <expr> <c-x><c-f> fzf#vim#complete#path(
      --   \ "find . -path '*/\.*' -prune -o print \| sed '1d;s:%..::'",
      --   \ fzf#wrap({'dir': expand('%:p:h')}))

      -- Load Git UI
      keymap("n", "<leader>gg", ":G<CR>", opts)

      -- When copying from the buffer in tmux, we wan't to get rid of visual
      -- aids like indent lines, line numbering, gutter
      function ToggleScreenMess()
        if string.lower(vim.o.signcolumn) == "auto" then
          vim.opt.number = false
          vim.opt.list = false
          vim.opt.relativenumber = false
          vim.o.signcolumn = "no"
          require('ibl').update { enabled = false }
        else
          vim.opt.number = true
          vim.opt.list = true
          vim.opt_local.relativenumber = false
          vim.o.signcolumn = "auto"
          require('ibl').update { enabled = true }
        end
      end
      keymap("n", "<leader>sc", "", {
        noremap = true,
        silent = true,
        callback = function(map) ToggleScreenMess() end,
      })

      -- replace the current buffer (delete) with bufexplorer
      --nnoremap <silent> <leader>bd :call <SID>BufDelete()<cr>

      -- Jump in and out of nvim tree
      keymap("n", "<leader>nt", "", {
        noremap = true,
        silent = true,
        callback = function(map)
          require('nvim-tree.api').tree.toggle()
        end,
      })
      keymap("n", "<leader>nf", "", {
        noremap = true,
        silent = true,
        callback = function(map)
          require('nvim-tree.api').tree.find_file {
            open = true,
            focus = true,
            update_root = true,
          }
        end,
      })
      keymap("n", "<leader>nn", "", {
        noremap = true,
        silent = true,
        callback = function(map)
          require('nvim-tree.api').tree.focus()
        end,
      })

      -- (C)reate (F)ile under cursor (for when `gf` doesn't work)
      --nnoremap <silent> <leader>cf :call writefile([], expand("<cfile>"), "t")<cr>

      -- base64 encode encode and decode visual selection
      --vnoremap <leader>6d c<c-r>=system('base64 --decode', @")<cr><esc>
      --vnoremap <leader>6e c<c-r>=system('base64 -w 0', @")<cr><esc>

      -- Push and close git interface
      --nnoremap <silent> <leader>gp :call <SID>GitPushAndClose()<CR>

      keymap("n", "<leader>ut", "", {
        noremap = true,
        silent = true,
        callback = function(map)
          vim.cmd.UndotreeToggle()
        end,
      })

      -- -----------------------------------------------------------------------
      -- LSP CONFIG
      -- -----------------------------------------------------------------------

      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        }),
      })

      local lspconfig = require('lspconfig')
      lspconfig.pyright.setup {}

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      keymap('n', '<space>e', "", {
        noremap = true,
        silent = true,
        callback = function(map) vim.diagnostic.open_float() end,
      })
      keymap('n', '[d', "", {
        noremap = true,
        silent = true,
        callback = function(map) vim.diagnostic.goto_prev() end,
      })
      keymap('n', ']d', "", {
        noremap = true,
        silent = true,
        callback = function(map) vim.diagnostic.goto_next() end,
      })
      keymap('n', '<spacq>e', "", {
        noremap = true,
        silent = true,
        callback = function(map) vim.diagnostic.setloclist() end,
      })

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    '';
    extraConfig = ''
      " VimScript Reminders:
      " 1) All autocommands should be in autogroups
      " 2) All functions should be prefixed with 's:' but use '<SID>' when
      "    calling from mappings or commands

      " #######################################################################
      " ****** PLUGIN SETTINGS ******
      " #######################################################################

      " #######################################################################
      " ****** PERSONAL FUNCTIONS ******
      " #######################################################################

      " Function so that we can push directly from Fugitive git index
      function! s:GitPushAndClose()
        exe ":Gpush"
        if getbufvar("", "fugitive_type") ==? "index"
          exe "wincmd c"
        endif
      endfunction

      " We make a persistent hidden buffer so that we have somewhere to go
      " while deleting the current buffer
      let s:BufDeleteBuffer = -1

      function! s:BufDelete()
        if s:BufDeleteBuffer == -1
          let s:BufDeleteBuffer = bufnr("BufDelete_".matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:], 1)
          call setbufvar(s:BufDeleteBuffer, "&buftype", "nofile")
        endif

        let l:cur_buffer = bufnr('%')
        exe "b ".s:BufDeleteBuffer
        exe "bdelete ".l:cur_buffer
        exe "BufExplorer"
      endfunction

      " #######################################################################
      " ****** LINE NUMBERING ******
      " #######################################################################

      " Show line numbers relative to the current cursor line to make repeated
      " commands easier to compose. We only do this while in the buffer.  When
      " focused in another buffer, we use standard numbering.

      function! s:InitLineNumbering()
        " Keep track of current window, since 'windo' changes current window
        let l:my_window = winnr()

        " Global line number settings
        set relativenumber
        set number
        set list
        set signcolumn=auto

        " Setup all windows for line numbering
        windo call s:SetLineNumberingForWindow(0)

        " Go back to window
        exec l:my_window . 'wincmd w'
        "
        " Set special (relative) numbering for focused window
        call s:SetLineNumberingForWindow(1)
      endfunction

      function! s:SetLineNumberingForWindow(entering)
        " Excluded buffers
        if &ft ==? "help" || exists("b:NERDTree")
          return
        endif
        if a:entering
          if &signcolumn ==? "auto"
            " Normal state, turn on relative number
            setlocal relativenumber
          else
            " Visual Indicators Disabled
            setlocal norelativenumber
          endif
        else
          setlocal norelativenumber
        endif
      endfunction

      augroup MyLineNumbers
        au!
        autocmd VimEnter * call <SID>InitLineNumbering()
        autocmd BufEnter,WinEnter * call <SID>SetLineNumberingForWindow(1)
        autocmd WinLeave * call <SID>SetLineNumberingForWindow(0)
      augroup END

      " #######################################################################
      " ****** LSP Configuration ******
      " #######################################################################

      " Use <Tab> and <S-Tab> to navigate through popup menu
      inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
      inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

      function! s:InitLSP()
      lua << EOLUA
        local nvim_lsp = require('lspconfig')
        local on_attach = function(client, bufnr)
          local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
          local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

          buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- Mappings.
          local opts = { noremap=true, silent=true }
          buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
          buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
          buf_set_keymap('n', 'gH', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
          buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
          buf_set_keymap('n', '<space>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
          buf_set_keymap('n', '<space>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
          buf_set_keymap('n', '<space>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
          buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
          buf_set_keymap('n', '<space>e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
          buf_set_keymap('n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
          buf_set_keymap('n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
          buf_set_keymap('n', '<space>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

          -- Set some keybinds conditional on server capabilities
          if client.resolved_capabilities.document_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
          elseif client.resolved_capabilities.document_range_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
          end

          -- Set autocommands conditional on server_capabilities
          if client.resolved_capabilities.document_highlight then
            vim.api.nvim_exec([[
              hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
              hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
              hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
              augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
              augroup END
            ]], false)
          end
        end

        -- Use a loop to simply setup all language servers
        local servers = { 'bashls', 'vimls' }
        -- Also: { 'sqls', 'rnix', 'efm', 'dartls' }
        for _, lsp in ipairs(servers) do
          nvim_lsp[lsp].setup { on_attach = on_attach }
        end
      EOLUA

        " Re-trigger filetype detection so LSP works on first file
        let &ft=&ft
      endfunction

      augroup MyLSPConfig
        au!
        " "autocmd VimEnter * call <SID>InitLSP()
        " "autocmd BufEnter * lua require'completion'.on_attach()
      augroup END
    '';
  };
}
