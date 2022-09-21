{ config, pkgs, ... }:
let
  # Custom neovim plugins
  vim-maximizer = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-maximizer";
    src = pkgs.fetchFromGitHub {
      owner = "szw";
      repo = "vim-maximizer";
      rev = "2e54952fe91e140a2e69f35f22131219fcd9c5f1";
      sha256 = "031brldzxhcs98xpc3sr0m2yb99xq0z5yrwdlp8i5fqdgqrdqlzr";
    };
    meta = {
      homepage = https://github.com/szw/vim-maximizer;
      maintainers = [ "szw" ];
    };
  };

  nvim-colorizer = pkgs.vimUtils.buildVimPlugin rec {
    name = "nvim-colorizer";
    src = pkgs.fetchFromGitHub {
      owner = "norcalli";
      repo = "nvim-colorizer.lua";
      rev = "36c610a9717cc9ec426a07c8e6bf3b3abcb139d6";
      sha256 = "0gvqdfkqf6k9q46r0vcc3nqa6w45gsvp8j4kya1bvi24vhifg2p9";
    };
    meta = {
      homepage = https://github.com/norcalli/nvim-colorizer.lua;
      maintainers = [ "norcalli" ];
    };
  };

  indent-blankline = pkgs.vimUtils.buildVimPlugin rec {
    name = "indent-blankline";
    src = pkgs.fetchFromGitHub {
      owner = "lukas-reineke";
      repo = "indent-blankline.nvim";
      rev = "d925b80b3f57c8e2bf913a36b37aa63b6ed75205";
      sha256 = "1h1jsjn6ldpx0qv7vk3isqs7hrfz1srv5q6vrf44lv2r5di1gr65";
    };
    meta = {
      homepage = https://github.com/lukas-reineke/indent-blankline.nvim;
      maintainers = [ "lukas-reineke" ];
    };
  };

  vim-glaive = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-glaive";
    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = "vim-glaive";
      rev = "c17bd478c1bc358dddf271a13a4a025efb30514d";
      sha256 = "0py6wqqnblr4n1xz1nwlxp0l65qmd76448gz0bf5q9a1sf0mkh5g";
    };
    meta = {
      homepage = https://github.com/google/vim-glaive;
      maintainers = [ "google" ];
    };
  };

  vim-syncopate = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-syncopate";
    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = "vim-syncopate";
      rev = "cc68632a72c269e8d75f1f22a6fa588fd5b46e02";
      sha256 = "0vb68h07wkqlwfr24s4nsxyclla60sii7lbg6wlgwhdn837hiqyx";
    };
    meta = {
      homepage = https://github.com/google/vim-syncopate;
      maintainers = [ "google" ];
    };
  };

  vim-fakeclip = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-fakeclip";
    src = pkgs.fetchFromGitHub {
      owner = "kana";
      repo = "vim-fakeclip";
      rev = "59858dabdb55787d7f047c4ab26b45f11ebb533b";
      sha256 = "1jrfi1vc7svhypvg2gizx40vracr91m9d912b61j0c7z8swix908";
    };
    meta = {
      homepage = https://github.com/kana/vim-fakeclip;
      maintainers = [ "kana" ];
    };
  };

  conflict-marker = pkgs.vimUtils.buildVimPlugin rec {
    name = "conflict-marker";
    src = pkgs.fetchFromGitHub {
      owner = "rhysd";
      repo = "conflict-marker.vim";
      rev = "6a9b8f92a57ea8a90cbf62c960db9e5894be2d7a";
      sha256 = "0vw5kvnmwwia65gni97vk42b9s47r3p5bglrhpcxsvs3f4s250vq";
    };
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

    extraConfig = ''
      " VimScript Reminders:
      " 1) All autocommands should be in autogroups
      " 2) All functions should be prefixed with 's:' but use '<SID>' when
      "    calling from mappings or commands

      " #######################################################################
      " ****** OVERALL SETTINGS ******
      " #######################################################################

      " I don't want files overriding my settings
      set modelines=0

      " I don't like beeping
      set visualbell

      " Enable 24-bit color support
      set termguicolors

      " I like to be able to occasionally use the mouse
      set mouse=a

      " Make sure we use Solarized light
      set background=light
      colorscheme NeoSolarized

      " Allow more-responsive async code
      set updatetime=100

      " Always show available completion options, but selection must be manual
      set completeopt=menuone,noinsert,noselect,longest

      " Don't show useless match messages while matching
      set shortmess+=c

      " Visual reminders of file width
      set colorcolumn=+1,+21,+41

      " Set visual characters for tabs and trailing whitespace.
      augroup VisualChars
        au!
        autocmd FileType * set listchars=tab:▸\ ,trail:☐
        autocmd FileType go set listchars=tab:\|\ ,trail:☐
      augroup END

      " Make sure that trailing whitespace is Red
      match errorMsg /\s\+$/

      " Make sure there is always at least 3 lines of context on either side of
      " the cursor (above and below).
      set scrolloff=3

      " These are my format options, use :help fo-table to understand
      set formatoptions+=rcoqnl1j

      " Make Y yank to the end of line, similar to D and C
      nnoremap Y y$

      " If w! doesn't work (because you're editing a root file), use w!! to save
      cnoremap <silent> w!! :exec ":echo ':w!!'"<CR>:%!sudo tee > /dev/null %

      " Add an insert mode mapping to reflow the current line.
      inoremap <C-G>q <C-O>gqq<C-O>A

      " I prefer my diffs vertical for side-by-side comparison
      set diffopt+=vertical

      " Default to case insensitive searching
      set ignorecase

      " Unless I use case in my search string, then case matters
      set smartcase

      " Keep unsaved files open with ther changes, even when switching buffers
      set hidden

      " Show the length of the visual selection while making it
      set showcmd

      " I speak english and french
      " set spell
      set spelllang=en_us,fr

      " Make backspace more powerful
      set backspace=indent,eol,start

      " Make tabs insert 'indents' when used at the beginning of the line
      set smarttab

      " Reasonable defaults for indentation
      set autoindent nocindent nosmartindent

      " Default to showing the current line (useful for long terminals)
      set cursorline

      " I find it useful to have lots of command history
      set history=1000

      " When joining lines, don't insert unnecessary whitespace
      set nojoinspaces

      " Have splits appear "after" current buffer
      set splitright splitbelow

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

      " Save the current undo state between launches
      set undofile
      set undolevels=1000
      set undoreload=10000

      " Set to only keep one (current) backup
      set backup writebackup

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

      augroup PersonalFileTypeSettings
        au!
        " Set up default spacing and tabs for a few filetypes.  I've left off Go,
        " since the filetype plugin handles it for me.
        autocmd FileType mail,text,python,gitcommit,c,cpp,java,sh,vim,puppet,xml,json,javascript,html,yaml,dart setlocal tabstop=8 shiftwidth=2 expandtab

        " Fix the comment handling, which is set to c-style by default
        autocmd FileType puppet setlocal commentstring=#\ %s

        " Standard GO tab settings (tabs, not spaces)
        autocmd FileType go setlocal tabstop=4 shiftwidth=4 noexpandtab

        " Turn on spellchecking in these file types.
        autocmd FileType mail,text,python,gitcommit,cpp setlocal spell

        " Help files trigger the 'text' filetype autocommand, but we don't want
        " spellchecking in the help buffer, so we manually disable it.
        autocmd FileType help setlocal nospell

        " Don't hide markdown punctuation
        autocmd FileType markdown set conceallevel=0

        " Teach vim-commentary about nasm comments
        autocmd FileType asm set commentstring=;\ %s

        " Ensure that we autowrap git commits to 72 characters, per tpope's guidelines
        " for good git comments.
        autocmd FileType gitcommit setlocal textwidth=72

        " I use 80-column lines in mail, plain text, C++ files, and my vimrc.
        autocmd FileType mail,text,vim,cpp,c setlocal textwidth=80

        " I use 100-column lines in Java files
        autocmd FileType java setlocal textwidth=100

        " Change line continuation rules for Java. j1 is for Java anonymous classes,
        " +2s says indent 2xshiftwidth on line continuations.
        autocmd FileType java setlocal cinoptions=j1,+2s
      augroup END

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
        " Keep track of current window, since 'windo' chances current window
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
