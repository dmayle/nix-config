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

  nvim-colorizer = pkgs.vimUtils.buildVimPlugin rec {
    name = "nvim-colorizer";
    src = inputs.nvim-colorizer;
    meta = {
      homepage = https://github.com/norcalli/nvim-colorizer.lua;
      maintainers = [ "norcalli" ];
    };
  };

  indent-blankline = pkgs.vimUtils.buildVimPlugin rec {
    name = "indent-blankline";
    src = inputs.indent-blankline;
    meta = {
      homepage = https://github.com/lukas-reineke/indent-blankline.nvim;
      maintainers = [ "lukas-reineke" ];
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

  conflict-marker = pkgs.vimUtils.buildVimPlugin rec {
    name = "conflict-marker";
    src = inputs.conflict-marker;
    meta = {
      homepage = https://github.com/rhysd/conflict-marker.vim;
      maintainers = [ "rhysd" ];
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

  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nix-community/neovim-nightly-overlay/tarball/0f13d55e4634ca7fcf956df0c76d1c1ffefb62a3;
  #     #url = https://github.com/nix-community/neovim-nightly-overlay/tarball/5e3737ae3243e2e206360d39131d5eb6f65ecff5;
  #   }))

  #   # For when I need to straight up override packages
  #   (self: super: {
  #     # Use nightly neovim as the basis for my regular neovim package
  #     neovim-unwrapped = self.neovim-nightly;
  #   })
  # ];

  home.file."${config.xdg.configHome}/nvim/spell/en.utf-8.spl".source = nvim-spell-en-utf8-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/en.utf-8.sug".source = nvim-spell-en-utf8-suggestions;
  home.file."${config.xdg.configHome}/nvim/spell/en.ascii.spl".source = nvim-spell-en-ascii-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/en.ascii.sug".source = nvim-spell-en-ascii-suggestions;
  home.file."${config.xdg.configHome}/nvim/spell/en.latin1.spl".source = nvim-spell-en-latin1-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/en.latin1.sug".source = nvim-spell-en-latin1-suggestions;
  home.file."${config.xdg.configHome}/nvim/spell/fr.utf-8.spl".source = nvim-spell-fr-utf8-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/fr.utf-8.sug".source = nvim-spell-fr-utf8-suggestions;
  home.file."${config.xdg.configHome}/nvim/spell/fr.latin1.spl".source = nvim-spell-fr-latin1-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/fr.latin1.sug".source = nvim-spell-fr-latin1-suggestions;

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

      # Automate the update and connection of tags files
      vim-gutentags

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
      nvim-colorizer

      # Both Indent guides plugins
      indent-blankline

      # Font for airline
      # powerline-fonts

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
      conflict-marker

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
      tagbar

      # Status bar with coloring
      vim-airline
      vim-airline-themes

      # Built-in debugger
      vimspector

      # Tag/source code explorer
      tagbar

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
      completion-nvim
    ];

    extraLuaConfig = ''
      -- -----------------------------------------------------------------------
      -- LOCAL NAMESPACE VARIABLES
      -- -----------------------------------------------------------------------
      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd
      local keymap = vim.keymap.set

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

        -- Set to only keep one (current) backup
        backup = true,
        writebackup = true,
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
      -- ALL BETS ARE OFF
      -- -----------------------------------------------------------------------

      -- Setting colorscheme is not an option, it's a call that needs to be
      -- made into vim. Normally I should check the return value here, but
      -- I don't know what I would do if it fails...
      pcall(vim.cmd, "colorscheme NeoSolarized")

      -- -----------------------------------------------------------------------
      -- AUTOCOMMAND GROUPS
      -- -----------------------------------------------------------------------
      local clear = { clear = true }
      local visualchars = augroup('VisualChars', clear)
      local filesettings = augroup('FileSettings', clear)
      local codfmtsettings = augroup('codfmtsettings', clear)
      local nvimtree = augroup('NvimTree', clear)
      local coloring = augroup('Coloring', clear)
      local linenumbers = augroup('LineNumbers', clear)
      local lspconfig = augroup('LSPConfig', clear)

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
    '';
    extraConfig = ''
      " VimScript Reminders:
      " 1) All autocommands should be in autogroups
      " 2) All functions should be prefixed with 's:' but use '<SID>' when
      "    calling from mappings or commands

      " Make sure that trailing whitespace is Red
      match errorMsg /\s\+$/

      " Make Y yank to the end of line, similar to D and C
      nnoremap Y y$

      " If w! doesn't work (because you're editing a root file), use w!! to save
      cnoremap <silent> w!! :exec ":echo ':w!!'"<CR>:%!sudo tee > /dev/null %

      " Add an insert mode mapping to reflow the current line.
      inoremap <C-G>q <C-O>gqq<C-O>A

      " #######################################################################
      " ****** BACKUP SETTINGS ******
      " #######################################################################

      " Use backup settings safe for NFS userdir mounts
      let $HOST=hostname()
      let $MYBACKUPDIR=$HOME . '/.vimbak-' . $HOST
      let $MYUNDODIR=$HOME . '/.vimundo-' . $HOST

      if !isdirectory(fnameescape($MYBACKUPDIR))
        silent! execute '!mkdir -p ' . shellescape($MYBACKUPDIR)
        silent! execute '!chmod 700 ' . shellescape($MYBACKUPDIR)
      endif

      if !isdirectory(fnameescape($MYUNDODIR))
        silent! execute '!mkdir -p ' . shellescape($MYUNDODIR)
        silent! execute '!chmod 700 ' . shellescape($MYUNDODIR)
      endif

      " Set directory for swap files
      set directory=$MYBACKUPDIR

      " Set directory for undo files
      set undodir=$MYUNDODIR

      " Set directory for backup files
      set backupdir=$MYBACKUPDIR

      " Sensible list of files we don't want backed up
      set backupskip=/tmp/*,/private/tmp/*,/var/tmp/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*

      " #######################################################################
      " ****** PLUGIN SETTINGS ******
      " #######################################################################

      " %%%%% Airline Status Line %%%%%
      " Match to overall vim theme
      let g:airline_theme='solarized'

      " %%%%% Promptline Bash Prompt Generator %%%%%
      " I only install Promptline when I update Airline, run this, then uninstall
      let g:promptline_theme = 'airline'
      " Solarized Bash Color Table For Theme:
      " 0 base2 (beige)
      " 1 red
      " 2 green
      " 3 yellow
      " 4 blue
      " 5 magenta
      " 6 cyan
      " 7 base02 (black)
      " 8 base3 (bright beige)
      " 9 orange
      " 10 base1 (lightest grey)
      " 11 base0 (light grey)
      " 12 base00 (dark grey)
      " 13 violet
      " 14 base01 (darkest grey)
      " 15 base03 (darkest black)
      " Colors I like:
      " Background: blue(4)  > yellow(3) > magenta(5) > bright beige(8)
      " Foreground: beige(0) > beige(0)  > beige(0)   > grey(11)
      " let g:promptline_preset = {
      "     \'a' : [ '\w' ],
      "     \'b' : [ '$(echo $(printf \\xE2\\x8E\\x88) $(kubectx -c)$(echo :$(kubens -c) | sed -e s@^:default\$@@))' ],
      "     \'c' : [ promptline#slices#vcs_branch() ],
      "     \'warn' : [ promptline#slices#last_exit_code() ]}

      " %%%%%%%%%% Indent Blankline %%%%%%%%%%
      " Enable treesitter support
      let g:indent_blankline_use_treesitter = v:true

      " %%%%% GutenTags %%%%%
      " Explanaiton of all this at https://www.reddit.com/r/vim/comments/d77t6j
      let g:gutentags_ctags_tagfile = '.tags'

      let g:gutentags_exclude_filetypes = [
            \ 'dart',
            \ ]

      " let g:gutentags_project_info = [
      "       \ {'type': 'dart', 'file': 'pubspec.yaml'},
      "       \ ]

      " let g:gutentags_ctags_executable_dart = '/home/douglas/.bin/flutter_ctags'

      let g:gutentags_ctags_extra_args = [
            \ '--tag-relative=yes',
            \ '--fields=+ailmnS',
            \ ]

      let g:gutentags_ctags_exclude = [
            \ '*.git', '*.svg', '*.hg',
            \ '*/tests/*',
            \ 'build',
            \ 'dist',
            \ '*sites/*/files/*',
            \ 'bazel-bin',
            \ 'bazel-out',
            \ 'bazel-projects',
            \ 'bazel-testlogs',
            \ 'bazel-*',
            \ 'bin',
            \ 'node_modules',
            \ 'bower_components',
            \ 'cache',
            \ 'compiled',
            \ 'docs',
            \ 'example',
            \ 'bundle',
            \ 'vendor',
            \ '*.md',
            \ '*-lock.json',
            \ '*.lock',
            \ '*bundle*.js',
            \ '*build*.js',
            \ '.*rc*',
            \ '*.json',
            \ '*.min.*',
            \ '*.map',
            \ '*.bak',
            \ '*.zip',
            \ '*.pyc',
            \ '*.class',
            \ '*.sln',
            \ '*.Master',
            \ '*.csproj',
            \ '*.tmp',
            \ '*.csproj.user',
            \ '*.cache',
            \ '*.pdb',
            \ 'tags*',
            \ 'cscope.*',
            \ '*.css',
            \ '*.less',
            \ '*.scss',
            \ '*.exe', '*.dll',
            \ '*.mp3', '*.ogg', '*.flac',
            \ '*.swp', '*.swo',
            \ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
            \ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
            \ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
            \ ]

      " #######################################################################
      " ****** FILETYPE SETTINGS ******
      " #######################################################################

      " Default to bash support in shell scripts
      let g:is_bash = 1

      augroup codefmt_autoformat_settings
        au!
        autocmd VimEnter * Glaive codefmt plugin[mappings]
        autocmd FileType bzl AutoFormatBuffer buildifier
        autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
        autocmd FileType dart AutoFormatBuffer dartfmt
        autocmd FileType go AutoFormatBuffer gofmt
        autocmd FileType gn AutoFormatBuffer gn
        autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
        autocmd FileType java AutoFormatBuffer google-java-format
        autocmd FileType python AutoFormatBuffer yapf
        " Alternative: autocmd FileType python AutoFormatBuffer autopep8
        autocmd FileType rust AutoFormatBuffer rustfmt
        autocmd FileType vue AutoFormatBuffer prettier
      augroup END

      " #######################################################################
      " ****** PERSONAL SHORTCUTS (LEADER) ******
      " #######################################################################

      nnoremap <Space> <Nop>
      let mapleader = ' '

      " Searches
      nnoremap <silent> <leader><space> :GFiles<CR>
      nnoremap <silent> <leader>ff :Rg<CR>
      inoremap <expr> <c-x><c-f> fzf#vim#complete#path(
        \ "find . -path '*/\.*' -prune -o print \| sed '1d;s:%..::'",
        \ fzf#wrap({'dir': expand('%:p:h')}))

      " Load Git UI
      nnoremap <silent> <leader>gg :G<cr>

      nnoremap <silent> <leader>pp :call <SID>TogglePaste()<cr>
      nnoremap <silent> <leader>sc :call <SID>ToggleScreenMess()<cr>

      " replace the current buffer (delete) with bufexplorer
      nnoremap <silent> <leader>bd :call <SID>BufDelete()<cr>

      " Jump in and out of nvim tree
      nnoremap <silent> <leader>nt :NvimTreeToggle<CR>
      nnoremap <silent> <leader>nf :NvimTreeFindFile<CR>
      nnoremap <silent> <leader>nn :call <SID>NvimTreeFocus()<cr>

      " (C)reate (F)ile under cursor (for when `gf` doesn't work)
      nnoremap <silent> <leader>cf :call writefile([], expand("<cfile>"), "t")<cr>

      nnoremap <silent> <leader>tt :TagbarToggle<CR>

      " base64 encode encode and decode visual selection
      vnoremap <leader>6d c<c-r>=system('base64 --decode', @")<cr><esc>
      vnoremap <leader>6e c<c-r>=system('base64 -w 0', @")<cr><esc>

      " Push and close git interface
      nnoremap <silent> <leader>gp :call <SID>GitPushAndClose()<CR>

      nnoremap <silent> <leader>ut :UndotreeToggle<CR>

      " #######################################################################
      " ****** PERSONAL FUNCTIONS ******
      " #######################################################################

      function! s:TogglePaste()
        if &paste
          set nopaste
        else
          set paste
        endif
      endfunction

      " When copying from the buffer in tmux, we wan't to get rid of visual
      " aids like indent lines, line numbering, gutter
      function! s:ToggleScreenMess()
        if &signcolumn ==? "auto"
          " Turn off
          set nonumber nolist norelativenumber signcolumn=no
          exe 'IndentBlanklineDisable'
        else
          " Turn on
          set number list signcolumn=auto
          setlocal relativenumber
          exe 'IndentBlanklineEnable'
        endif
      endfunction

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

      function! s:NvimTreeFocus()
        " This function is meant to be used if NvimTree is already open, but
        " let's assume I meant to open it when trying to focus it.
        exe ":NvimTreeOpen"
        let l:nvim_tree_buffer = bufwinnr("NvimTree")
        if l:nvim_tree_buffer != -1
          exe l:nvim_tree_buffer."wincmd w"
        endif
      endfunction

      function! s:InitNvimTree()
        lua require'nvim-tree'.setup{ filters = { custom = { '.git', '^bazel-.*$' } } }
      endfunction

      augroup MyNvimTree
        au!
        autocmd VimEnter * call <SID>InitNvimTree()
      augroup END

      " #######################################################################
      " ****** COLORING CONTENT ******
      " #######################################################################

      function! s:InitColoring()
        lua require'colorizer'.setup()
        lua require'colorizer'.attach_to_buffer(0)
      endfunction

      augroup MyColoring
        au!
        autocmd VimEnter * call <SID>InitColoring()
      augroup END

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
        autocmd VimEnter * call <SID>InitLSP()
        autocmd BufEnter * lua require'completion'.on_attach()
      augroup END
    '';
  };
}
