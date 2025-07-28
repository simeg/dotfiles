-- Core Neovim Options
-- Based on your existing vim configuration

local opt = vim.opt

-- Disable vim compatibility
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

-- General
opt.compatible = false         -- Disable vi compatibility
opt.hidden = true              -- Leave hidden buffers open
opt.history = 1000             -- Command history cap (increased from 100)
opt.undolevels = 1000          -- Undo levels (increased from 200)
opt.mouse = 'a'                -- Enable mouse cursor
opt.clipboard = 'unnamedplus'  -- Use system clipboard (improved from vim)
opt.wildmenu = true            -- Enhance CLI completion
opt.backspace = {'indent', 'eol', 'start'}  -- Allow backspace in insert mode
opt.encoding = 'utf-8'         -- UTF-8 encoding
opt.scrolloff = 5              -- Keep 5 lines visible above/below cursor

-- Leader keys
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- Backup and undo
opt.backup = true
opt.backupdir = vim.fn.stdpath('cache') .. '/nvim/backups'
opt.directory = vim.fn.stdpath('cache') .. '/nvim/swaps'
opt.undofile = true
opt.undodir = vim.fn.stdpath('cache') .. '/nvim/undo'

-- Create backup directories if they don't exist
local backup_dirs = {
  vim.fn.stdpath('cache') .. '/nvim/backups',
  vim.fn.stdpath('cache') .. '/nvim/swaps',
  vim.fn.stdpath('cache') .. '/nvim/undo'
}

for _, dir in ipairs(backup_dirs) do
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
end

-- Skip backups for sensitive locations
opt.backupskip = {'/tmp/*', '/private/tmp/*'}

-- Display
opt.number = true              -- Enable line numbers
opt.relativenumber = true      -- Relative line numbers (modern improvement)
opt.cursorline = true          -- Highlight current line
opt.colorcolumn = '80'         -- Show vertical line at 80 characters
opt.signcolumn = 'yes'         -- Always show sign column (for git, lsp, etc.)
opt.wrap = false               -- Don't wrap long lines
opt.termguicolors = true       -- Enable 24-bit RGB colors

-- Completely disable vim's built-in syntax system (neovim 0.11.3 fix)
-- We'll use treesitter exclusively for syntax highlighting
vim.g.syntax_on = 0
vim.g.loaded_syntax_completion = 1

-- Disable the problematic system syntax files
vim.g.did_load_filetypes = 1
vim.g.did_indent_on = 1

-- Enable only filetype detection and plugin loading
vim.cmd('filetype plugin on')

-- Skip all syntax-related autocmds and use treesitter instead
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    -- Ensure treesitter is loaded and handling syntax
    pcall(function()
      if vim.fn.exists(':TSEnable') == 2 then
        vim.cmd('TSEnable highlight')
      end
    end)
  end,
})

-- Search
opt.hlsearch = true            -- Highlight searches
opt.incsearch = true           -- Highlight dynamically as pattern is typed
opt.ignorecase = true          -- Ignore case of searches
opt.smartcase = true           -- Override ignorecase if search contains capitals

-- Status and command line
opt.laststatus = 3             -- Global statusline (neovim feature)
opt.cmdheight = 1              -- Command line height
opt.showmode = false           -- Don't show mode (we have statusline)
opt.showcmd = true             -- Show partial commands
opt.ruler = true               -- Show cursor position

-- Notifications
opt.errorbells = false         -- Disable error bells
opt.visualbell = true          -- Use visual bell

-- Title and messages
opt.title = true               -- Show filename in window titlebar
opt.shortmess:append('c')      -- Don't show completion messages

-- Indentation (matching your vim config)
opt.autoindent = true
opt.smartindent = true
opt.smarttab = true
opt.tabstop = 2
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2

-- Completion
opt.completeopt = {'menu', 'menuone', 'noselect'}  -- Better completion experience
opt.pumheight = 10             -- Limit popup menu height

-- Spell checking
opt.spelllang = 'en'
opt.spell = false              -- Disabled by default, toggle with keybind

-- Performance
opt.updatetime = 250           -- Faster CursorHold events
opt.timeoutlen = 300           -- Faster key sequence timeout

-- Security
opt.modeline = true            -- Respect modeline in files
opt.modelines = 4
opt.secure = true              -- Disable unsafe commands in local config files

-- Split behavior
opt.splitright = true          -- Vertical splits go to the right
opt.splitbelow = true          -- Horizontal splits go below

-- Folding (enhanced from vim)
opt.foldmethod = 'indent'      -- Fold based on indentation
opt.foldlevelstart = 99        -- Start with all folds open

-- Session options
opt.sessionoptions = {'buffers', 'curdir', 'help', 'tabpages', 'winsize'}