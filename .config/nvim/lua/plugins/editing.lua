-- Editing Enhancements
-- Configuration for various editing plugins

-- Comment.nvim setup (replacement for vim-commentary)
local status_ok, comment = pcall(require, 'Comment')
if status_ok then
  comment.setup()
end

-- nvim-autopairs setup (replacement for delimitMate)
local autopairs_ok, autopairs = pcall(require, 'nvim-autopairs')
if autopairs_ok then
  autopairs.setup({
    check_ts = true, -- Enable treesitter integration
    ts_config = {
      lua = { 'string', 'source' },
      javascript = { 'string', 'template_string' },
      java = false,
    },
    disable_filetype = { 'TelescopePrompt', 'vim' },
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = [=[[%'%"%)%>%]%)%}%,]]=],
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      highlight = 'PmenuSel',
      highlight_grey = 'LineNr'
    },
  })

  -- Integration with nvim-cmp
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmp_status_ok, cmp = pcall(require, 'cmp')
  if cmp_status_ok then
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end
end

-- Rainbow delimiters setup (replacement for rainbow_parentheses.vim)
local rainbow_ok, rainbow = pcall(require, 'rainbow-delimiters.setup')
if rainbow_ok then
  -- Configuration is handled automatically
end

-- Which-key setup (helpful for discovering keybindings)
local which_key_ok, which_key = pcall(require, 'which-key')
if which_key_ok then
  which_key.add({
    -- File operations
    { '<leader>f', group = 'find' },
    { '<leader>ff', desc = 'Find files' },
    { '<leader>fg', desc = 'Live grep' },
    { '<leader>fb', desc = 'Find buffers' },
    { '<leader>fh', desc = 'Find help' },

    -- Git operations
    { '<leader>g', group = 'git' },
    { '<leader>gp', desc = 'Preview hunk' },
    { '<leader>gs', desc = 'Stage hunk' },
    { '<leader>gr', desc = 'Reset hunk' },
    { '<leader>gb', desc = 'Blame line' },
    { '<leader>gt', desc = 'Toggle line blame' },

    -- Toggle operations
    { '<leader>t', group = 'toggle' },
    { '<leader>tb', desc = 'Toggle git blame' },
    { '<leader>td', desc = 'Toggle deleted' },

    -- Single key operations
    { '<leader>c', desc = 'Clear search highlights' },
    { '<leader>n', desc = 'Toggle file tree' },
    { '<leader>s', desc = 'Toggle spell check' },
    { '<leader>i', desc = 'Toggle comment' },

    -- LSP operations
    { '<leader>r', group = 'refactor' },
    { '<leader>rn', desc = 'Rename symbol' },
    { '<leader>rf', desc = 'Format code' },
    { '<leader>ca', desc = 'Code actions' },
    { '<leader>e', desc = 'Show diagnostics' },
    { '<leader>q', desc = 'Diagnostic list' },

    -- Navigation
    { 'gd', desc = 'Go to definition' },
    { 'gD', desc = 'Go to declaration' },
    { 'gi', desc = 'Go to implementation' },
    { 'K', desc = 'Hover documentation' },
    { '[d', desc = 'Previous diagnostic' },
    { ']d', desc = 'Next diagnostic' },
  })
end
