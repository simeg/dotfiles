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
opt.relativenumber = false     -- Disable relative line numbers
opt.cursorline = true          -- Highlight current line
opt.colorcolumn = '80'         -- Show vertical line at 80 characters
opt.signcolumn = 'yes'         -- Always show sign column (for git, lsp, etc.)
opt.wrap = false               -- Don't wrap long lines
opt.termguicolors = true       -- Enable 24-bit RGB colors

-- Enable basic syntax highlighting and filetype detection
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

-- Override with treesitter when available
vim.api.nvim_create_autocmd('User', {
  pattern = 'LazyVimStarted',
  callback = function()
    -- Enable treesitter highlighting when lazy is ready
    vim.schedule(function()
      pcall(function()
        local ts_highlight = require('nvim-treesitter.highlight')
        local ts_config = require('nvim-treesitter.configs')
        if ts_highlight and ts_config then
          -- Enable treesitter highlighting
          vim.cmd('TSEnable highlight')

          -- Disable additional vim regex highlighting since we have treesitter
          vim.api.nvim_create_autocmd('BufEnter', {
            callback = function()
              vim.opt_local.syntax = 'off'
            end,
          })
        end
      end)
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

-- Folding (disabled - no automatic folding)
opt.foldmethod = 'manual'      -- Manual folding only
opt.foldenable = false         -- Disable folding by default
opt.foldlevel = 99             -- Keep all folds open
opt.foldlevelstart = 99        -- Start with all folds open

-- Session options
opt.sessionoptions = {'buffers', 'curdir', 'help', 'tabpages', 'winsize'}