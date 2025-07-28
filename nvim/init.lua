-- Neovim Configuration
-- Modern replacement for vim configuration

-- Immediate fix for neovim 0.11.3 syntax loading bug
-- This must be done before any other initialization
vim.g.syntax_on = 0

-- Load core settings
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- Plugin management
require('plugins.lazy')

-- Load plugin configurations
require('plugins.colorscheme')
require('plugins.lualine')
require('plugins.nvim-tree')
require('plugins.treesitter')
require('plugins.telescope')
require('plugins.lsp')
require('plugins.completion')
require('plugins.git')
require('plugins.editing')
