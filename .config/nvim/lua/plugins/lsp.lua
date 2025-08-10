-- LSP Configuration

-- optional: bail if lspconfig missing
local ok_lsp, lspconfig = pcall(require, 'lspconfig')
if not ok_lsp then
  return
end

-- Capability helper (nvim-cmp optional)
local has_cmp, cmp_caps = pcall(require, 'cmp_nvim_lsp')
local capabilities = has_cmp and cmp_caps.default_capabilities()
  or vim.lsp.protocol.make_client_capabilities()

-- Your keymaps etc.
local on_attach = function(_, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  local map = function(lhs, rhs) vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true }) end
  map('gD', vim.lsp.buf.declaration)
  map('gd', vim.lsp.buf.definition)
  map('K',  vim.lsp.buf.hover)
  map('gi', vim.lsp.buf.implementation)
  map('<C-k>', vim.lsp.buf.signature_help)
  map('<leader>rn', vim.lsp.buf.rename)
  map('<leader>ca', vim.lsp.buf.code_action)
  map('gr', vim.lsp.buf.references)
  map('<leader>rf', function() vim.lsp.buf.format({ async = true }) end)
end

-- Global defaults for ALL servers
vim.lsp.config('*', {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Per‑server tweaks (override/extend)
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('', true),
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config('yamlls', {
  settings = { yaml = { keyOrdering = false } },
})

-- Mason bootstrap + auto‑enable installed servers
require('mason').setup()

require('mason-lspconfig').setup({
  ensure_installed = {
    'pyright',
    'bashls',
    'yamlls',
    'jsonls',
    'marksman',
    'taplo',   -- TOML
    'lua_ls',
  },
  automatic_enable = true,
})
