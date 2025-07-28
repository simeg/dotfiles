-- Colorscheme Configuration
-- Matches your existing vim colorscheme setup

-- Set background before loading colorscheme
vim.opt.background = 'dark'

-- Load gruvbox colorscheme (matching your vim config)
local status_ok, _ = pcall(vim.cmd, 'colorscheme gruvbox')
if not status_ok then
  vim.notify('colorscheme gruvbox not found!')
  return
end

-- Gruvbox specific settings (matching your vim config)
vim.g.gruvbox_contrast_dark = 'medium'
vim.g.gruvbox_improved_strings = 1
vim.g.gruvbox_improved_warnings = 1