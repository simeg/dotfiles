-- LSP Configuration

local ok_lsp, lspconfig = pcall(require, 'lspconfig')
if not ok_lsp then return end

-- Capabilities (nvim-cmp -> LSP)
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp, cmp_caps = pcall(require, 'cmp_nvim_lsp')
if ok_cmp then
  capabilities = cmp_caps.default_capabilities(capabilities)
end

-- on_attach: buffer-local keymaps etc.
local on_attach = function(_, bufnr)
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end
  map('gD', vim.lsp.buf.declaration,       'LSP: Declaration')
  map('gd', vim.lsp.buf.definition,        'LSP: Definition')
  map('K',  vim.lsp.buf.hover,             'LSP: Hover')
  map('gi', vim.lsp.buf.implementation,    'LSP: Implementation')
  map('<C-k>', vim.lsp.buf.signature_help, 'LSP: Signature Help')
  map('<leader>rn', vim.lsp.buf.rename,    'LSP: Rename')
  map('<leader>ca', vim.lsp.buf.code_action,'LSP: Code Action')
  map('gr', vim.lsp.buf.references,        'LSP: References')
  map('<leader>rf', function() vim.lsp.buf.format({ async = true }) end, 'LSP: Format')

  -- Optional: inlay hints if your Neovim supports it
  if vim.lsp.inlay_hint then
    vim.keymap.set('n', '<leader>ih', function()
      local enabled = vim.lsp.inlay_hint.is_enabled(bufnr)
      vim.lsp.inlay_hint.enable(bufnr, not enabled)
    end, { buffer = bufnr, desc = 'LSP: Toggle Inlay Hints' })
  end
end

-- Per-server overrides
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file('', true) },
        telemetry = { enable = false },
      },
    },
  },
  yamlls = {
    settings = { yaml = { keyOrdering = false } },
  },
  -- Add server-specific settings here if you want (pyright, jsonls, etc.)
}

-- Mason bootstrap + mason-lspconfig
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'pyright',
    'bashls',
    'yamlls',
    'jsonls',
    'marksman',
    'taplo',
    'lua_ls',
  },
  automatic_installation = true, -- this one exists
})

-- Set up each server manually
local mason_lspconfig = require('mason-lspconfig')
local installed_servers = mason_lspconfig.get_installed_servers()

for _, server_name in ipairs(installed_servers) do
  local opts = {
    on_attach = on_attach,
    capabilities = capabilities,
  }
  if servers[server_name] then
    for k, v in pairs(servers[server_name]) do
      opts[k] = v
    end
  end
  lspconfig[server_name].setup(opts)
end
