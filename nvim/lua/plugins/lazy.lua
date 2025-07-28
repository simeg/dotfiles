-- Plugin Manager Setup (Lazy.nvim)
-- Modern replacement for vim-plug

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Color schemes (matching your vim setup)
  {
    'morhetz/gruvbox',
    priority = 1000,
    config = function()
      vim.g.gruvbox_contrast_dark = 'medium'
      vim.g.gruvbox_improved_strings = 1
      vim.g.gruvbox_improved_warnings = 1
    end,
  },
  
  {
    'junegunn/seoul256.vim',
    priority = 1000,
  },

  -- File explorer (NERDTree replacement)
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup({
        filters = {
          dotfiles = false, -- Show hidden files (matching your NERDTree config)
        },
      })
    end,
  },

  -- Statusline (airline replacement)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Fuzzy finder (modern improvement)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  -- Treesitter (better syntax highlighting)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },

  -- Git integration (gitgutter replacement)
  {
    'lewis6991/gitsigns.nvim',
  },

  -- Comments (vim-commentary replacement)
  {
    'numToStr/Comment.nvim',
  },

  -- Auto pairs (delimitMate replacement)
  {
    'windwp/nvim-autopairs',
  },

  -- Zen mode (Goyo replacement)
  {
    'folke/zen-mode.nvim',
  },

  -- Rainbow parentheses
  {
    'HiPhish/rainbow-delimiters.nvim',
  },

  -- Better whitespace handling
  {
    'ntpeters/vim-better-whitespace',
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
  },

  -- Mason (LSP installer)
  {
    'williamboman/mason.nvim',
  },
  {
    'williamboman/mason-lspconfig.nvim',
  },

  -- Completion (completor.vim replacement)
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
  },

  -- Language support
  {
    'pangloss/vim-javascript',
    ft = 'javascript',
  },
  
  {
    'plasticboy/vim-markdown',
    ft = 'markdown',
  },

  -- CSS
  {
    'hail2u/vim-css3-syntax',
    ft = 'css',
  },

  -- HTML
  {
    'othree/html5.vim',
    ft = 'html',
  },

  -- Markdown preview
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function() vim.fn['mkdp#util#install']() end,
  },

  -- Additional modern plugins
  {
    'folke/which-key.nvim', -- Show available keybindings
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup()
    end,
  },

  {
    'echasnovski/mini.icons', -- Better icons support
    version = false,
    config = function()
      require('mini.icons').setup()
    end,
  },

  {
    'lukas-reineke/indent-blankline.nvim', -- Show indentation lines
    main = 'ibl',
    opts = {},
  },

  -- Terminal enhancement
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = true,
  },
}, {
  -- Lazy.nvim configuration
  ui = {
    border = 'rounded',
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})