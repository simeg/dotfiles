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
  -- Folke meta-pack: bigfile/quickfile speed-ups, indent guides, notifier
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {},
      quickfile = {},
      indent = {},
      notifier = {},
    },
  },

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

  -- Edit the filesystem like a buffer (batch rename/move)
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    opts = {
      view_options = { show_hidden = true },
    },
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Open parent directory in Oil' },
    },
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
    -- Repo archived 2026-04-03; the new `main` branch is an incompatible
    -- rewrite. Pin to `master` to stay on the frozen-but-working version.
    branch = 'master',
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

  -- Comments are now provided by Neovim 0.10+ builtin (gc/gcc).
  -- See keymaps.lua for the <leader>i remap onto gcc/gc.

  -- Format-on-save orchestration
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    opts = {
      format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        go = { 'gofmt' },
        rust = { 'rustfmt' },
      },
    },
  },

  -- Pretty diagnostics, references, quickfix list
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    opts = {},
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',          desc = 'Diagnostics' },
      { '<leader>xr', '<cmd>Trouble lsp_references toggle<cr>',       desc = 'LSP references' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<cr>',  desc = 'Symbols' },
    },
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
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { 'f', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash jump' },
      { '<leader>c', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash jump' },
      { '<leader>l', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash treesitter' },
    },
  },

  { 'rafamadriz/friendly-snippets' },

}, {
  -- Lazy.nvim configuration
  ui = {
    border = 'rounded',
  },
  rocks = {
    enabled = false, -- No plugins need luarocks; silences hererocks warnings
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
