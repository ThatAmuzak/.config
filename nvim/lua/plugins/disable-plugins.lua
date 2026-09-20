-- Central list of disabled plugins / modules.
-- Treesitter stays enabled for highlighting.
return {
  -- LSP engines
  { "neovim/nvim-lspconfig", enabled = false },
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "folke/lazydev.nvim", enabled = false },

  -- Formatting / linting (Mason-dependent diagnostics producers)
  { "stevearc/conform.nvim", enabled = false },
  { "mfussenegger/nvim-lint", enabled = false },

  -- Diagnostics UI
  { "folke/trouble.nvim", enabled = false },

  -- Trimmed for lean quick-edit startup
  { "folke/todo-comments.nvim", enabled = false },
  { "windwp/nvim-ts-autotag", enabled = false },
  { "folke/persistence.nvim", enabled = false },

  -- Tab/buffer line
  { "akinsho/bufferline.nvim", enabled = false },

  -- Notification / overlay UI
  { "folke/noice.nvim", enabled = false },

  -- Snacks modules to turn off (snacks itself stays for dashboard, picker, terminal, etc.)
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      explorer = { enabled = false },
      notifier = { enabled = false },
      terminal = {
        win = { wo = { winbar = "" } },
      },
      picker = {
        sources = {
          explorer = { enabled = false },
        },
      },
    },
  },
}
