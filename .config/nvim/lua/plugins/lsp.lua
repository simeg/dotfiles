-- LSP Configuration (Neovim 0.11+ native API)

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

  -- Inlay hints toggle
  if vim.lsp.inlay_hint then
    vim.keymap.set('n', '<leader>ih', function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
    end, { buffer = bufnr, desc = 'LSP: Toggle Inlay Hints' })
  end
end

-- Per-server settings
local server_settings = {
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
}

-- Mason setup
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
  automatic_installation = true,
})

-- Configure LSP servers using new vim.lsp.config API
local mason_lspconfig = require('mason-lspconfig')
local installed_servers = mason_lspconfig.get_installed_servers()

for _, server_name in ipairs(installed_servers) do
  local config = {
    on_attach = on_attach,
    capabilities = capabilities,
  }
  -- Merge server-specific settings
  if server_settings[server_name] then
    config = vim.tbl_deep_extend('force', config, server_settings[server_name])
  end
  vim.lsp.config(server_name, config)
  vim.lsp.enable(server_name)
end
