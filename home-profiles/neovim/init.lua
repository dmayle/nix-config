-- -----------------------------------------------------------------------------
-- LOCAL NAMESPACE VARIABLES
-- -----------------------------------------------------------------------------
-- Easy accessors for nvim api calls
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.keymap.set
local kopts = { silent = true }

-- Accessor for libuv
local uv = vim.loop

-- We put hostname into these paths so that a home directory which is on top of
-- NFS and shared across hosts will not have conflicts
local host = uv.os_gethostname()
local homedir = os.getenv("HOME")
local backupdir = string.format("%s/.vimbak-$s", homedir, host)
local undodir = string.format("%s/.vimundo-$s", homedir, host)

-- -----------------------------------------------------------------------------
-- GLOBAL SETTINGS
-- -----------------------------------------------------------------------------

-- Disable builtin netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Default to bash support in shell scripts
vim.g.is_bash = 1

-- Enable conflict marker mappings
vim.g.conflict_marker_enable_mappings = 1

-- Use treesitter for indent blanklines plugin
vim.g.indent_blankline_use_treesitter = true

-- Lua table of options which will be set directly into vim options
local options = {
  -- ---------------------------------------------------------------------------
  -- OVERALL SETTINGS
  -- ---------------------------------------------------------------------------

  -- I don't want files overriding my settings
  modelines     = 0,

  -- I don't like beeping
  visualbell    = true,

  -- Enable 24-bit color support
  termguicolors = true,

  -- We want to use Solarized light, but setting colorscheme is not an option,
  -- so that comes later
  background    = "light",

  -- Always show available completion options, but selection must be manual
  completeopt   = { "menuone", "noselect", "noinsert" },

  -- Default to case insensitive searching
  ignorecase    = true,

  -- Unless I use case in my search string, then case matters
  smartcase     = true,

  -- I like to be able to occasionally use the mouse
  mouse         = "a",

  -- My status bar shows vim modes
  showmode      = false,

  -- Trying out an always on tabline
  showtabline   = 2,

  -- Have splits appear "after" current buffer
  splitright    = true,
  splitbelow    = true,

  -- Allow more-responsive async code (fire event 0.1s after typing stops)
  updatetime    = 100,

  -- Trigger multi-key sequence 0.5s after typing stops
  -- (instead of waiting for additional keys, defaults to 1s)
  timeoutlen    = 500,

  -- Default to showing the current line (useful for long terminals)
  cursorline    = true,

  -- Make sure there is always at least 3 lines of context on either side of
  -- the cursor (above and below).
  scrolloff     = 3,

  -- ---------------------------------------------------------------------------
  -- Filetype setting defaults below, overridden per-language
  -- ---------------------------------------------------------------------------

  -- Indentation defaults, overridden per-language
  autoindent    = true,
  cindent       = false,
  smartindent   = false,

  -- Unless I'm in go or a makefile, I never want tabs
  expandtab     = true,

  -- Two spaces is reasonable for indent levels by default
  tabstop       = 2, -- treat tab characters as 2 spaces (rare, expandtab above)
  shiftwidth    = 2, -- increase and decrease 2 spaces with tab key

  -- Visual reminders of file width
  colorcolumn   = { "+1", "+21", "+41" },

  -- Make tabs insert 'indents' when used at the beginning of the line
  smarttab      = true,

  -- Keep unsaved files open with ther changes, even when switching buffers
  hidden        = true,

  -- Show the length of the visual selection while making it
  showcmd       = true,

  -- I speak english and french, but only turn on for certain filetypes
  spelllang     = { "en_us", "fr" },

  -- Make backspace more powerful
  backspace     = { "indent", "eol", "start" },

  -- I find it useful to have lots of command history
  history       = 1000,

  -- When joining lines, don't insert unnecessary whitespace
  joinspaces    = false,

  -- Save the current undo state between launches
  undofile      = true,
  undolevels    = 1000,
  undoreload    = 10000,

  -- Set directory for swap files
  directory     = backupdir,

  -- Set directory for undo files
  undodir       = undodir,

  -- Set directory for backup files
  backupdir     = backupdir,

  -- Set to only keep one (current) backup
  backup        = true,
  writebackup   = true,

  -- Sensible list of files we don't want backed up
  backupskip    =
  '/tmp/*,/private/tmp/*,/var/tmp/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*',
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- -----------------------------------------------------------------------------
-- MODIFY DEFAULT SETTINGS
-- -----------------------------------------------------------------------------

-- Don't show useless match messages while matching
vim.opt.shortmess:append "c"

-- Have vim treat hyphen as part of character for word commands like "*"
vim.opt.iskeyword:append "-"

-- These are my format options, use :help fo-table to understand
vim.opt.formatoptions:append 'rcoqnl1j'

-- I prefer my diffs vertical for side-by-side comparison
vim.opt.diffopt:append "vertical"

-- -----------------------------------------------------------------------------
-- MKDIRP: UTILITY FOR RECURSIVE DIRECTORY CREATION
-- -----------------------------------------------------------------------------

local isWindows
if _G["jit"] then
  isWindows = _G["jit"].os == "Windows"
else
  isWindows = not not package.path:match("\\")
end

local function dirparent(dir)
  local sep
  if isWindows then
    sep = "\\"
  else
    sep = "/"
  end
  if not dir then
    return sep
  end
  local result, _ = string.gsub(dir, string.format("%s[^%s]*$", sep, sep), "")
  return result
end

local function mkdirp(path, mode, callback)
  uv.fs_stat(backupdir, function(stat_err, stat)
    if not stat_err then
      if stat.type ~= "directory" then
        stat_err = string.format("Cannot create %s: File exists")
        callback(stat_err, nil)
        return
      end
      -- Success!
      callback(nil, true)
      return
    end
    uv.fs_mkdir(path, mode, function(mkdir_err, mkdir_success)
      if mkdir_success or string.match(mkdir_err, "^EEXIST:") then
        -- Worked, or created during race, success!
        callback(nil, true)
        return
      end
      if string.match(mkdir_err, "^ENOENT:") then
        -- The containing directory (which mkdir uses) does not exist
        mkdirp(dirparent(path), mode, function(mkdirp_err, mkdirp_success)
          if mkdirp_success then
            -- Replay original dir creation once only
            uv.fs_mkdir(path, mode, function(retry_err, success)
              if success or string.match(retry_err, "^EEXIST:") then
                -- Worked, or created during race, success!
                callback(nil, true)
                return
              end
              -- Propagate any mkdir error
              callback(retry_err, nil)
            end)
            return
          end
          -- Propagate error from creating parent directory
          callback(mkdirp_err, nil)
        end)
        return
      end
      -- Propagate unknown mkdir error
      callback(mkdir_err, nil)
    end)
  end)
end

-- -----------------------------------------------------------------------------
-- CREATE NECESSARY BACKUP/UNDO DIRECTORIES
-- -----------------------------------------------------------------------------

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

-- -----------------------------------------------------------------------------
-- AUTOCOMMAND GROUPS
-- -----------------------------------------------------------------------------
local clear = { clear = true }
local visualchars = augroup('VisualChars', clear)
local filesettings = augroup('FileSettings', clear)
local linenumbers = augroup('LineNumbers', clear)

-- -----------------------------------------------------------------------------
-- AUTOCOMMANDS
-- -----------------------------------------------------------------------------
-- VISUAL CHARACTERS
-- -----------------------------------------------------------------------------

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

-- -----------------------------------------------------------------------------
-- FILETYPE SETTINGS
-- -----------------------------------------------------------------------------

autocmd({ 'FileType' }, {
  desc = "Set up default spacing and tabs for a few filetypes.  I've left off \z
          Go, since the filetype plugin handles it for me.",
  group = filesettings,
  pattern = { "mail", "text", "python", "gitcommit", "c", "cpp", "java", "sh",
    "vim", "puppet", "xml", "json", "javascript", "html", "yaml", "dart" },
  callback = function()
    vim.opt_local.tabstop = 8
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

autocmd({ 'FileType' }, {
  desc = "Use 80-column lines for some file types",
  group = filesettings,
  pattern = { "mail", "text", "lua", "vim", "c", "cpp", "nix" },
  callback = function()
    vim.opt_local.textwidth = 80
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
  desc = "Ensure that we autowrap git commits to 72 characters, per tpope's \z
          guidelines for good git comments.",
  group = filesettings,
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.textwidth = 72
  end,
})

autocmd({ 'FileType' }, {
  desc = "For Java, I use custom continuation rules and 100-column lines.",
  group = filesettings,
  pattern = "java",
  callback = function()
    vim.opt_local.textwidth = 100
    -- Change line continuation rules for Java. j1 is for Java anonymous
    -- classes, +2s says indent 2xshiftwidth on line continuations.
    vim.opt_local.cinoptions = "j1,+2s"
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
  desc = "Help files are both text and help, triggering spellchecking, so we \z
          manually disable it for them",
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

-- -----------------------------------------------------------------------------
-- CUSTOM LINE NUMBERING
-- -----------------------------------------------------------------------------

function InitLineNumbering()
  -- Global line number settings
  vim.opt.relativenumber = true;
  vim.opt.number = true;
  vim.opt.list = true;
  vim.o.signcolumn = "auto"

  for _, handle in ipairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_win_set_option(handle, "relativenumber", false)
  end

  local enable = string.lower(vim.o.signcolumn) == "auto"
  vim.api.nvim_win_set_option(0, "relativenumber", enable)
end

function SetLineNumberingForWindow(entering)
  local ft = string.lower(vim.bo.filetype)
  if ft == "help" or ft == "nvimtree" then
    return
  end
  if entering then
    local enable = string.lower(vim.o.signcolumn) == "auto"
    vim.api.nvim_win_set_option(0, "relativenumber", enable)
  else
    vim.api.nvim_win_set_option(0, "relativenumber", false)
  end
end

autocmd({ 'VimEnter' }, {
  desc = "Initialize my line numbering setup",
  group = linenumbers,
  callback = InitLineNumbering,
})
autocmd({ 'BufEnter', 'WinEnter' }, {
  desc = "Set per-window, per-buffer line numbering",
  group = linenumbers,
  callback = function() SetLineNumberingForWindow(true) end,
})
autocmd({ 'WinLeave' }, {
  desc = "Reset per-window, per-buffer line numbering to normal",
  group = linenumbers,
  callback = function() SetLineNumberingForWindow(false) end,
})

-- -----------------------------------------------------------------------------
-- PLUGIN SETTINGS
-- -----------------------------------------------------------------------------
-- NEOSOLARIZED.NVIM (Solarized color scheme)
-- -----------------------------------------------------------------------------

require('NeoSolarized').setup {
  style = "light",
  transparent = false,
  terminal_colors = true,
  enable_italics = true,
}

-- Setting colorscheme is not an option, it's a call that needs to be made into
-- vim. Normally I should check the return value here, but I don't know what
-- I would do if it fails...
pcall(vim.cmd, "colorscheme NeoSolarized")

-- -----------------------------------------------------------------------------
-- LUA PLUGINS (Default Configurations)
-- -----------------------------------------------------------------------------

require('Comment').setup()        -- Mappings for code comments
require('bufferline').setup()     -- Buffers as 'tabs'
require('outline').setup {}       -- Code outline window like tagbar.vim
require('nvim-autopairs').setup() -- Add closing parens, quotes, etc.
require('ibl').setup()            -- Add indentation visual aids


-- -----------------------------------------------------------------------------
-- LSPLINES CONFIG (Inline floating diagnostics)
-- -----------------------------------------------------------------------------

local lsp_lines = require('lsp_lines')
lsp_lines.setup()
vim.diagnostic.config({ virtual_lines = true, virtual_text = false })

-- -----------------------------------------------------------------------------
-- COLORIZER CONFIG (Colorizes words: Blue White Red or symbols: #00FF00)
-- -----------------------------------------------------------------------------

local colorizer = require('colorizer')
colorizer.setup()
colorizer.attach_to_buffer(0)

-- -----------------------------------------------------------------------------
-- LSP-FORMAT CONFIG (Code formatter)
-- -----------------------------------------------------------------------------

-- on_attach must be called for each language server
require('lsp-format').setup()

-- -----------------------------------------------------------------------------
-- LUALINE CONFIG (Status bar at bottom of window)
-- -----------------------------------------------------------------------------

require('lualine').setup {
  options = {
    theme = 'NeoSolarized',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', {
      'diagnostics',
      sources = { 'nvim_lsp', 'nvim_diagnostic' },
      sections = { 'error', 'warn', 'info', 'hint' },
      colored = true,
      update_in_insert = false,
      always_visible = false,
    } },
    lualine_c = { 'filename', 'lsp_progress' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  extensions = {
    'fzf', 'fugitive', 'man', 'nvim-tree',
  },
}

-- -----------------------------------------------------------------------------
-- NVIM-TREE CONFIG (File Explorer)
-- -----------------------------------------------------------------------------

require('nvim-tree').setup({
  filters = {
    custom = { '.git', '^bazel-.*$' }
  }
})

-- -----------------------------------------------------------------------------
-- GITSIGNS CONFIG (Git status markers)
-- -----------------------------------------------------------------------------

require('gitsigns').setup {
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "▎" },
    topdelete = { text = "▎" },
    changedelete = { text = "▎" },
  },
  signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
  numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
  linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
  word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
  on_attach = function()
    local gitsigns = require('gitsigns')

    keymap("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gitsigns.next_hunk()
      end
    end)

    keymap("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gitsigns.prev_hunk()
      end
    end)

    keymap("n", "<leader>hp", gitsigns.preview_hunk)
  end,
}

-- -----------------------------------------------------------------------------
-- TELESCOPE CONFIG (Floating fuzzy search window)
-- -----------------------------------------------------------------------------

require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
}
-- Load native fzf plugin
require('telescope').load_extension('fzf')

-- -----------------------------------------------------------------------------
-- CMP CONFIG (Autocomplete suport)
-- -----------------------------------------------------------------------------

local cmp = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

-- load from friendly-snippets
require("luasnip/loaders/from_vscode").lazy_load()

local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ['<C-y>'] = cmp.mapping.disable, -- Removes default mapping
    ['<C-e>'] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      menu = ({
        nvim_lua = "[Lua Nvim]",
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
        ["nil"] = "[Nil]",
      }),
    }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  },
})

-- -----------------------------------------------------------------------------
-- LSP CONFIG
-- -----------------------------------------------------------------------------

local lspconfig = require('lspconfig')

-- -----------------------------------------------------------------------------
-- LANGUAGE SERVERS (Default Configurations)
-- -----------------------------------------------------------------------------

lspconfig.nil_ls.setup {}
lspconfig.pyright.setup {}
lspconfig.rust_analyzer.setup {}
-- Use ts_ls instead
lspconfig.ts_ls.setup {}

-- -----------------------------------------------------------------------------
-- LUA LANGUAGE SERVERS (Recognize vim global)
-- -----------------------------------------------------------------------------

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}

-- -----------------------------------------------------------------------------
-- KEY MAPPINGS
-- -----------------------------------------------------------------------------
-- PERSONAL SHORTCUTS (LEADER)
-- -----------------------------------------------------------------------------

keymap("", "<Space>", "<Nop>", kopts)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Make Y mirror y, working like D and C, yank to the end of the line
keymap("n", "Y", "y$", kopts)

-- Add an insert mode mapping to reflow the current line.
keymap("i", "<C-G>q", "<C-O>gqq<C-O>A", kopts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", kopts)
keymap("n", "<C-j>", "<C-w>j", kopts)
keymap("n", "<C-k>", "<C-w>k", kopts)
keymap("n", "<C-l>", "<C-w>l", kopts)

-- Easier buffer navigation
keymap("n", "H", ":bprev <CR>", kopts)
keymap("n", "L", ":bnext <CR>", kopts)

-- Allow arrows to resize windows
keymap("n", "<C-Up>", ":resize -2<CR>", kopts)
keymap("n", "<C-Down>", ":resize +2<CR>", kopts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", kopts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", kopts)

-- Move current line up or down
keymap("n", "<A-j>", ":m .+1<CR>==", kopts)
keymap("n", "<A-k>", ":m .-2<CR>==", kopts)

-- Move visual selection up or down
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", kopts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", kopts)

-- Move visual block selection up or down
keymap("x", "<A-j>", ":m '>+1<CR>gv=gv", kopts)
keymap("x", "<A-k>", ":m '<-2<CR>gv=gv", kopts)

-- Load Git UI
keymap("n", "<leader>gg", ":G<CR>", kopts)

-- base64 encode encode and decode visual selection
--vnoremap <leader>6d c<c-r>=system('base64 --decode', @")<cr><esc>
--vnoremap <leader>6e c<c-r>=system('base64 -w 0', @")<cr><esc>

keymap("n", "<leader>ut", vim.cmd.UndotreeToggle, kopts)

keymap("n", "<leader>ol", function() vim.cmd("Outline!") end)

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
keymap('n', '<leader>e', vim.diagnostic.open_float, kopts)
keymap('n', '[d', vim.diagnostic.goto_prev, kopts)
keymap('n', ']d', vim.diagnostic.goto_next, kopts)
keymap('n', '[D', function() vim.diagnostic.goto_prev({ cursor_position = { 1, 0 }, wrap = true }) end, kopts)
keymap('n', ']D', function() vim.diagnostic.goto_next({ cursor_position = { 1, 0 } }) end, kopts)
keymap('n', '<leader>q', vim.diagnostic.setloclist, kopts)

keymap('n', '<leader>ll', lsp_lines.toggle, kopts)

-- -----------------------------------------------------------------------------
-- BUFDELETE (Delete buffer without closing window)
-- -----------------------------------------------------------------------------

local bufdelete = require("bufdelete").bufdelete
keymap("n", "<leader>bd", function() bufdelete(0) end, kopts)

-- -----------------------------------------------------------------------------
-- ILLUMINATE (Navigate to next highlighted word)
-- -----------------------------------------------------------------------------
local illuminate = require('illuminate')
keymap('n', ']i', illuminate.goto_next_reference, kopts)
keymap('n', '[i', illuminate.goto_prev_reference, kopts)

-- -----------------------------------------------------------------------------
-- TELESCOPE (Common searches)
-- -----------------------------------------------------------------------------
local telescope = require('telescope.builtin')
keymap('n', '<leader>fg', telescope.live_grep, {})
keymap('n', '<leader>ff', telescope.find_files, {})
keymap('n', '<leader><space>', telescope.find_files, {})
keymap('n', '<leader>fb', telescope.buffers, {})
keymap('n', '<leader>fh', telescope.help_tags, {})

-- -----------------------------------------------------------------------------
-- TROUBLE (Diagnostic viewer)
-- -----------------------------------------------------------------------------
local trouble = require('trouble')
trouble.setup()
keymap('n', '<leader>xx', function() trouble.toggle("diagnostics") end, {})
keymap('n', '<leader>xw', function() trouble.toggle("workspace_diagnostics") end, {})
keymap('n', '<leader>xd', function() trouble.toggle("document_diagnostics") end, {})
keymap('n', '<leader>xq', function() trouble.toggle("quickfix") end, {})
keymap('n', '<leader>xl', function() trouble.toggle("loclist") end, {})
keymap('n', '<leader>xr', function() trouble.toggle("lsp_references") end, {})

-- -----------------------------------------------------------------------------
-- Clear visual aids so screen copy works
-- -----------------------------------------------------------------------------

local function toggle_screen_mess()
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

keymap("n", "<leader>sc", toggle_screen_mess, kopts)

-- -----------------------------------------------------------------------------
-- Add comma or semicolon to end of line without breaking flow
-- -----------------------------------------------------------------------------

local function append_to_line(content)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
  local column = string.len(line[1])
  vim.api.nvim_buf_set_text(0, row - 1, column, row - 1, column, { content })
end

keymap("i", "<C-;>", function() append_to_line(";") end, kopts)
keymap("i", "<C-,>", function() append_to_line(",") end, kopts)


-- -----------------------------------------------------------------------------
-- NVIM-TREE (Toggle, focus, find current file)
-- -----------------------------------------------------------------------------

local nvim_tree = require('nvim-tree.api').tree
keymap("n", "<leader>nt", nvim_tree.toggle, kopts)
keymap("n", "<leader>nn", nvim_tree.focus, kopts)

keymap("n", "<leader>nf", function()
  nvim_tree.find_file {
    open = true,
    focus = true,
    update_root = true,
  }
end, kopts)

-- -----------------------------------------------------------------------------
-- (C)reate (F)ile under cursor (for when `gf` doesn't work)
-- -----------------------------------------------------------------------------

local function create_file_under_cursor()
  local file_under_cursor = vim.fn.expand("<cfile>")
  uv.fs_open(file_under_cursor, 'xw', 384, function(err, fd) -- 384 == 0600
    if err then
      print(string.format("Error creating file: %s", err))
    else
      uv.fs_close(fd)
    end
  end)
end

keymap("n", "<leader>cf", create_file_under_cursor, kopts)

-- -----------------------------------------------------------------------------
-- FUGITIVE GIT PUSH AND CLOSE WINDOW
-- -----------------------------------------------------------------------------

-- Push and close git interface
local function git_push_and_close()
  vim.cmd('Gpush')
  local status_ok, ftype = pcall(
    vim.api.nvim_buf_get_var, 0, "fugitive_type")
  if status_ok and string.lower(ftype) == "index" then
    vim.api.nvim_win_close(0, false)
  end
end

keymap("n", "<leader>gp", git_push_and_close, kopts)

-- -----------------------------------------------------------------------------
-- LSP KEYMAPPINGS (Use LspAttach to only map after language server is attached)
-- -----------------------------------------------------------------------------

autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    if vim.lsp.formatexpr then
      vim.bo[ev.buf].formatexpr = 'v:lua.vim.lsp.formatexpr'
    end
    if vim.lsp.tagfunc then
      vim.bo[ev.buf].tagfunc = 'v:lua.vim.lsp.tagfunc'
    end

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local lsp_opts = { buffer = ev.buf }
    keymap('n', 'gD', vim.lsp.buf.declaration, lsp_opts)
    keymap('n', 'gd', vim.lsp.buf.definition, lsp_opts)
    keymap('n', 'K', vim.lsp.buf.hover, lsp_opts)
    keymap('n', 'gi', vim.lsp.buf.implementation, lsp_opts)
    keymap('n', 'gr', vim.lsp.buf.references, lsp_opts)
    keymap('n', 'gl', vim.diagnostic.open_float, lsp_opts)

    -- W mappings (Workspace)
    keymap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, lsp_opts)
    keymap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, lsp_opts)
    keymap('n', '<leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, lsp_opts)

    -- L mappings (LSP)
    keymap('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end, lsp_opts)
    keymap('n', '<leader>li', function() vim.cmd([[:LspInfo]]) end, lsp_opts)
    keymap({ 'n', 'v' }, '<leader>la', vim.lsp.buf.code_action, lsp_opts)
    keymap('n', '<leader>lr', vim.lsp.buf.rename, lsp_opts)
    keymap('n', '<leader>ls', vim.lsp.buf.signature_help, lsp_opts)
  end,
})
