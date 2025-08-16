-- Keymaps for Neovim
-- Based on your existing vim keybindings with modern improvements

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key is set in options.lua as ','

-- Core mappings from your vim config
keymap('i', 'jk', '<Esc><Esc>:w<CR>', opts)  -- Exit insert mode and save
keymap('n', '<leader>s', ':set spell!<CR>', opts)  -- Toggle spelling
keymap('n', '<leader>c', ':nohlsearch<CR>', opts)  -- Clear search highlights

-- Disable Ex mode (Q)
keymap('n', 'Q', '<NOP>', opts)

-- Disable arrow keys (maintaining your vim discipline)
keymap('n', '<Up>', '<NOP>', opts)
keymap('n', '<Down>', '<NOP>', opts)
keymap('n', '<Left>', '<NOP>', opts)
keymap('n', '<Right>', '<NOP>', opts)
keymap('i', '<Up>', '<NOP>', opts)
keymap('i', '<Down>', '<NOP>', opts)
keymap('i', '<Left>', '<NOP>', opts)
keymap('i', '<Right>', '<NOP>', opts)

-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- Resize windows with arrows (when not disabled globally)
keymap('n', '<C-Up>', ':resize -2<CR>', opts)
keymap('n', '<C-Down>', ':resize +2<CR>', opts)
keymap('n', '<C-Left>', ':vertical resize -2<CR>', opts)
keymap('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Navigate buffers
keymap('n', '<S-l>', ':bnext<CR>', opts)
keymap('n', '<S-h>', ':bprevious<CR>', opts)

-- Better indenting
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- Move text up and down
keymap('v', '<A-j>', ':m .+1<CR>==', opts)
keymap('v', '<A-k>', ':m .-2<CR>==', opts)
keymap('x', 'J', ':move \'>+1<CR>gv-gv', opts)
keymap('x', 'K', ':move \'<-2<CR>gv-gv', opts)
keymap('x', '<A-j>', ':move \'>+1<CR>gv-gv', opts)
keymap('x', '<A-k>', ':move \'<-2<CR>gv-gv', opts)

-- Keep cursor centered when scrolling
keymap('n', '<C-d>', '<C-d>zz', opts)
keymap('n', '<C-u>', '<C-u>zz', opts)
keymap('n', 'n', 'nzzzv', opts)
keymap('n', 'N', 'Nzzzv', opts)

-- Better paste (don't overwrite register when pasting over selection)
keymap('x', '<leader>p', [["_dP]], opts)

-- Delete to void register
keymap('n', '<leader>d', [["_d]], opts)
keymap('v', '<leader>d', [["_d]], opts)

-- Copy to system clipboard
keymap('n', '<leader>y', [["+y]], opts)
keymap('v', '<leader>y', [["+y]], opts)
keymap('n', '<leader>Y', [["+Y]], opts)

-- Plugin-specific keymaps (will be available when plugins load)

-- File explorer (nvim-tree replaces NERDTree)
keymap('n', '<leader>n', ':NvimTreeToggle<CR>', opts)

-- Telescope (modern fuzzy finder)
keymap('n', '<leader>ff', ':Telescope find_files<CR>', opts)
keymap('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>fb', ':Telescope buffers<CR>', opts)
keymap('n', '<leader>fh', ':Telescope help_tags<CR>', opts)

-- LSP keymaps (will be set up in lsp config)
keymap('n', 'gd', vim.lsp.buf.definition, opts)
keymap('n', 'gD', vim.lsp.buf.declaration, opts)
keymap('n', 'gr', vim.lsp.buf.references, opts)
keymap('n', 'gi', vim.lsp.buf.implementation, opts)
keymap('n', 'K', vim.lsp.buf.hover, opts)
keymap('n', '<leader>rn', vim.lsp.buf.rename, opts)
keymap('n', '<leader>ca', vim.lsp.buf.code_action, opts)
keymap('n', '<leader>rf', function() vim.lsp.buf.format { async = true } end, opts)

-- Diagnostic keymaps
keymap('n', '[d', vim.diagnostic.goto_prev, opts)
keymap('n', ']d', vim.diagnostic.goto_next, opts)
keymap('n', '<leader>e', vim.diagnostic.open_float, opts)
keymap('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- Git (will be available with git plugins)
keymap('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', opts)
keymap('n', '<leader>gt', ':Gitsigns toggle_current_line_blame<CR>', opts)

-- Comments (using Comment.nvim, similar to vim-commentary)
keymap('n', '<leader>i', function()
  require('Comment.api').toggle.linewise.current()
end, opts)

keymap('x', '<leader>i', function()
  local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
  require('Comment.api').toggle.linewise(vim.fn.visualmode())
end, opts)

-- Terminal
keymap('n', '<leader>t', ':terminal<CR>', opts)
keymap('t', '<Esc>', '<C-\\><C-n>', opts)  -- Exit terminal mode

-- Quick save and quit
keymap('n', '<leader>w', ':w<CR>', opts)
keymap('n', '<leader>q', ':q<CR>', opts)
keymap('n', '<leader>x', ':x<CR>', opts)

-- Source config
keymap('n', '<leader><leader>s', ':source ~/.config/nvim/init.lua<CR>', opts)