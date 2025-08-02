-- Neovim Configuration
-- Modern replacement for vim configuration

-- Immediate fix for neovim 0.11.3 syntax loading bug
-- This must be done before any other initialization
-- vim.g.syntax_on = 0

vim.g.bigfile_size=1024*1024*1 -- 1M

-- Load core settings
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- Plugin management (this loads all plugins including colorscheme)
require('plugins.lazy')

-- Load additional plugin configurations after lazy setup
-- Note: lazy.nvim handles most plugin loading automatically
-- These are for additional configurations not handled by lazy setup
require('plugins.lualine')
require('plugins.nvim-tree')
require('plugins.telescope')
require('plugins.lsp')
require('plugins.completion')
require('plugins.git')
require('plugins.editing')
