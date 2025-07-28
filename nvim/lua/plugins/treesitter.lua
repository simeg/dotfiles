return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          -- Web
          "html", "css", "javascript", "typescript", "tsx", "json",
          -- Backend / Systems
          "lua", "python", "rust", "go", "bash", "c", "cpp", "java", "ruby",
          -- Config / Markup
          "yaml", "toml", "ini", "markdown", "markdown_inline", "regex",
          -- Extras
          "vim", "vimdoc", "make", "dockerfile", "gitcommit", "gitignore"
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },
}
