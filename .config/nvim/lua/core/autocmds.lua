-- Autocommands for Neovim
-- Based on your existing vim autocommands with modern improvements

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General settings augroup
local general = augroup('General', { clear = true })

-- Highlight on yank
autocmd('TextYankPost', {
  group = general,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- Remove whitespace on save (matching your vim config)
autocmd('BufWritePre', {
  group = general,
  pattern = '*',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})

-- Don't auto comment new lines
autocmd('BufEnter', {
  group = general,
  pattern = '*',
  command = 'set fo-=c fo-=r fo-=o',
})

-- File type specific settings
local filetype = augroup('FileType', { clear = true })

-- Force syntax highlighting (from your vim config)
autocmd({'BufNewFile', 'BufRead'}, {
  group = filetype,
  pattern = '*.html.twig',
  command = 'set syntax=html',
})

autocmd({'BufNewFile', 'BufRead'}, {
  group = filetype,
  pattern = '*.js',
  command = 'set syntax=javascript',
})

autocmd({'BufNewFile', 'BufRead'}, {
  group = filetype,
  pattern = '*.py',
  command = 'set syntax=python',
})

autocmd({'BufNewFile', 'BufRead'}, {
  group = filetype,
  pattern = '*.md',
  command = 'set filetype=markdown',
})

autocmd({'BufNewFile', 'BufRead'}, {
  group = filetype,
  pattern = '*.json',
  command = 'setfiletype json | set syntax=javascript',
})

-- Format JSON files when opening (from your vim config)
autocmd('FileType', {
  group = filetype,
  pattern = 'json',
  callback = function()
    if vim.fn.executable('jq') == 1 then
      vim.cmd('silent %!jq .')
    end
  end,
})

-- Resize splits when window is resized
autocmd('VimResized', {
  group = general,
  pattern = '*',
  command = 'wincmd =',
})

-- Close some filetypes with <q>
autocmd('FileType', {
  group = general,
  pattern = {
    'qf',
    'help',
    'man',
    'lspinfo',
    'spectre_panel',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

-- Check if we need to reload the file when it changed
autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = general,
  command = 'checktime',
})

-- Go to last location when opening a buffer
autocmd('BufReadPost', {
  group = general,
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Terminal settings
local terminal = augroup('Terminal', { clear = true })

autocmd('TermOpen', {
  group = terminal,
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
    vim.cmd('startinsert')
  end,
})

-- LSP settings
local lsp = augroup('LSP', { clear = true })

-- Show line diagnostics automatically in hover window
autocmd('CursorHold', {
  group = lsp,
  pattern = '*',
  callback = function()
    vim.diagnostic.open_float(nil, {
      focusable = false,
      close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
      border = 'rounded',
      source = 'always',
      prefix = ' ',
      scope = 'cursor',
    })
  end,
})

-- Language-specific settings
local languages = augroup('Languages', { clear = true })

-- Python
autocmd('FileType', {
  group = languages,
  pattern = 'python',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Go
autocmd('FileType', {
  group = languages,
  pattern = 'go',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = false
  end,
})

-- Markdown
autocmd('FileType', {
  group = languages,
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})