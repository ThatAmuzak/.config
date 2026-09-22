-- Oil.nvim replaces the built-in file tree (Snacks explorer)
return {
  {
    "folke/snacks.nvim",
    -- LazyVim v16 auto-imports the snacks_explorer extra, which maps
    -- <leader>e / <leader>E / <leader>fe / <leader>fE. These `false`
    -- entries delete those keymaps from the merged snacks spec.
    keys = {
      { "<leader>e", false },
      { "<leader>E", false },
      { "<leader>fe", false },
      { "<leader>fE", false },
    },
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
