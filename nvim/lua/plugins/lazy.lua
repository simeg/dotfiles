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
  -- Color schemes
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup({
        flavour = 'frappe', -- latte, frappe, macchiato, mocha
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          treesitter = true,
          which_key = true,
          mason = true,
        },
      })
      vim.cmd.colorscheme('catppuccin')
    end,
  },

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
    lazy = false,
    priority = 900,
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'lua', 'vim', 'vimdoc', 'html', 'css', 'javascript', 'python', 'bash', 'json', 'yaml', 'markdown' },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
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

  -- Smooth scrolling
  {
    'karb94/neoscroll.nvim',
    config = function()
      require('neoscroll').setup({
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = 'quadratic',
        pre_hook = nil,
        post_hook = nil,
      })
    end,
  },

  -- Better notifications
  {
    'rcarriga/nvim-notify',
    config = function()
      require('notify').setup({
        background_colour = '#000000',
        fps = 30,
        icons = {
          DEBUG = '',
          ERROR = '',
          INFO = '',
          TRACE = '✎',
          WARN = ''
        },
        level = 2,
        minimum_width = 50,
        render = 'default',
        stages = 'fade_in_slide_out',
        timeout = 5000,
        top_down = true
      })
      vim.notify = require('notify')
    end,
  },

  -- Rust Cargo.toml helper
  {
    'saecki/crates.nvim',
    event = { 'BufRead Cargo.toml' },
    config = function()
      require('crates').setup({
        src = {
          cmp = {
            enabled = true,
          },
        },
        null_ls = {
          enabled = true,
          name = 'crates.nvim',
        },
        popup = {
          autofocus = true,
          hide_on_select = true,
          copy_register = '"',
          style = 'minimal',
          border = 'rounded',
          show_version_date = false,
          show_dependency_version = true,
          max_height = 30,
          min_width = 20,
          padding = 1,
        },
      })
    end,
  },

  -- Fast navigation (jump to any location)
  {
    'smoka7/hop.nvim',
    version = '*',
    config = function()
      require('hop').setup({
        keys = 'etovxqpdygfblzhckisuran',
        jump_on_sole_occurrence = true,
        case_insensitive = true,
        create_hl_autocmd = true,
      })

      -- Set up keymaps
      local hop = require('hop')
      local directions = require('hop.hint').HintDirection

      -- Jump to any word (using 'f' as requested)
      vim.keymap.set('', 'f', function()
        hop.hint_words()
      end, { desc = 'Hop to word' })

      -- Jump to any character
      vim.keymap.set('', '<leader>c', function()
        hop.hint_char1()
      end, { desc = 'Hop to character' })

      -- Jump to any line
      vim.keymap.set('', '<leader>l', function()
        hop.hint_lines()
      end, { desc = 'Hop to line' })
    end,
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
