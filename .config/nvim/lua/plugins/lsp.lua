-- LSP Configuration
-- Language Server Protocol setup

local status_ok, _ = pcall(require, 'lspconfig')
if not status_ok then
  return
end

-- Mason setup (LSP installer)
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'lua_ls',
    'bashls',
    'jsonls',
    'yamlls',
    'marksman', -- Markdown
  },
})

-- LSP settings
local lspconfig = require('lspconfig')

-- Common on_attach function
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Buffer local mappings
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<leader>rf', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- Common capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Lua LSP
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- Bash LSP
lspconfig.bashls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- JSON LSP
lspconfig.jsonls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- YAML LSP
lspconfig.yamlls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Markdown LSP
lspconfig.marksman.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})