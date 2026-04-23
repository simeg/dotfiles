-- Plugin Manager Setup (Lazy.nvim)
-- Modern replacement for vim-plug

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
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
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          -- Web
          'html', 'css', 'javascript', 'typescript', 'tsx', 'json',
          -- Backend / Systems
          'lua', 'python', 'rust', 'go', 'bash', 'c', 'cpp', 'java', 'ruby',
          -- Config / Markup
          'yaml', 'toml', 'ini', 'markdown', 'markdown_inline', 'regex',
          -- Extras
          'vim', 'vimdoc', 'make', 'dockerfile', 'gitcommit', 'gitignore',
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })

      vim.treesitter.language.register('bash', 'zsh')
    end,
  },

  -- Git integration (gitgutter replacement)
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    config = function() require('plugins.git') end,
  },

  -- Comments (vim-commentary replacement): loaded on-demand via require('Comment.api') in keymaps.lua
  {
    'numToStr/Comment.nvim',
    lazy = true,
    opts = {},
  },

  -- Auto pairs (delimitMate replacement)
  {
    'windwp/nvim-autopairs',
  },


  -- Rainbow parentheses
  {
    'HiPhish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
  },

  -- Better whitespace handling
  {
    'ntpeters/vim-better-whitespace',
    event = 'VeryLazy',
  },

  -- LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      require('plugins.lsp') -- <— all the real work lives here now
    end,
  },

  -- Completion (completor.vim replacement)
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind.nvim',
    },
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
      vim.o.timeoutlen = 300 -- This is the sweet spot
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
    event = 'BufReadPost',
    main = 'ibl',
    opts = {},
  },

  -- Terminal enhancement
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    cmd = { 'ToggleTerm', 'TermExec', 'ToggleTermToggleAll' },
    config = true,
  },

  -- Smooth scrolling
  {
    'karb94/neoscroll.nvim',
    event = 'VeryLazy',
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
    event = 'VeryLazy',
    config = function()
      require('notify').setup({
        background_colour = '#000000',
        fps = 30,
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
    ft = 'toml',
    config = function()
      require('crates').setup({
        lsp = {
          enabled = true,
          actions = true,
          completion = true,
          hover = true,
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
        }
      })
    end,
  },

  -- Fast navigation (jump to any location)
  {
    'smoka7/hop.nvim',
    version = '*',
    keys = {
      { 'f', function() require('hop').hint_words() end, mode = { 'n', 'v', 'o' }, desc = 'Hop to word' },
      { '<leader>c', function() require('hop').hint_char1() end, mode = { 'n', 'v', 'o' }, desc = 'Hop to character' },
      { '<leader>l', function() require('hop').hint_lines() end, mode = { 'n', 'v', 'o' }, desc = 'Hop to line' },
    },
    opts = {
      keys = 'etovxqpdygfblzhckisuran',
      jump_on_sole_occurrence = true,
      case_insensitive = true,
      create_hl_autocmd = true,
    },
  },

  { 'rafamadriz/friendly-snippets' },

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
