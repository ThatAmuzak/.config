-- Oil.nvim replaces the built-in file tree (Snacks explorer)
return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
      picker = {
        sources = {
          explorer = { enabled = false },
        },
      },
    },
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    keys = {
      { "<leader>e", ":Oil<CR>", desc = "Open Oil (file explorer)" },
    },
    opts = {
      default_file_explorer = true,
    },
  },
}
