-- Treesitter Configuration
-- Better syntax highlighting and code understanding

local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

treesitter.setup {
  -- A list of parser names, or "all"
  ensure_installed = {
    'bash',
    'css',
    'html',
    'javascript',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'typescript',
    'vim',
    'yaml',
    'toml',
    'gitignore',
    'dockerfile',
    'make',
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { '' },

  highlight = {
    -- Enable treesitter highlighting (replaces vim syntax entirely)
    enable = true,

    -- Disable for these languages (empty list means enable for all)
    disable = {},

    -- Completely disable vim regex highlighting to prevent conflicts
    additional_vim_regex_highlighting = false,
  },

  indent = {
    enable = true,
    disable = { 'yaml' },
  },

  -- Incremental selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },

  -- Text objects
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
  },
}