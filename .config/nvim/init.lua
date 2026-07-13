-- Neovim Configuration
-- Modern replacement for vim configuration

-- Immediate fix for neovim 0.11.3 syntax loading bug
-- This must be done before any other initialization
-- vim.g.syntax_on = 0

-- Load core settings
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- Plugin management (this loads all plugins including colorscheme)
require('plugins.lazy')

-- Load additional plugin configurations after lazy setup
-- Note: lazy.nvim handles most plugin loading automatically
-- These are for additional configurations not handled by lazy setup
-- plugins.completion is NOT required here: it runs as nvim-cmp's config
-- callback (see lazy.lua) so cmp keeps its InsertEnter lazy-load.
require('plugins.lualine')
require('plugins.nvim-tree')
require('plugins.telescope')
require('plugins.editing')
