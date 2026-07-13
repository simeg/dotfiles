-- Editing Enhancements
-- Configuration for various editing plugins

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

  -- The nvim-cmp integration lives in plugins/completion.lua: requiring cmp
  -- here would force-load it at startup (lazy.nvim auto-loads plugins on
  -- require) and defeat its InsertEnter lazy-load.
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

    -- Toggle operations (gitsigns buffer-local maps)
    { '<leader>t', group = 'toggle' },
    { '<leader>tb', desc = 'Toggle git blame' },
    { '<leader>td', desc = 'Toggle deleted' },
    { '<leader>T', desc = 'Open terminal' },

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

    -- Diagnostics lists (shared prefix with trouble's <leader>xx/xr/xs)
    { '<leader>x', group = 'diagnostics' },
    { '<leader>xl', desc = 'Diagnostics to loclist' },

    -- Navigation
    { 'gd', desc = 'Go to definition' },
    { 'gD', desc = 'Go to declaration' },
    { 'gi', desc = 'Go to implementation' },
    { 'K', desc = 'Hover documentation' },
    { '[d', desc = 'Previous diagnostic' },
    { ']d', desc = 'Next diagnostic' },
  })
end
