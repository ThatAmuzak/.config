-- Override LazyVim's default flash.nvim (it ships core) with the user's
-- preferred behavior: rainbow hues, custom highlight groups, char mode off,
-- and leader-based keymaps instead of the default s/S/r/R binds.
return {
  {
    "folke/flash.nvim",
    keys = {
      -- remove LazyVim defaults
      { "s", false },
      { "S", false },
      { "r", false },
      { "R", false },
      { "<c-s>", false },
      { "<c-space>", false },
      -- user bindings
      {
        "<leader>ff",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "<leader>zs",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
    opts = {
      rainbow = {
        enabled = true,
        shade = 5,
      },
      highlight = {
        backdrop = true,
        groups = {
          match = "FlashMatch",
          current = "FlashCurrent",
          backdrop = "FlashBackdrop",
          label = "FlashLabel",
        },
      },
      modes = {
        char = {
          enabled = false,
        },
      },
    },
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "FlashMatch", { bg = "#4A47A3", fg = "#B8B5FF" })
      vim.api.nvim_set_hl(0, "FlashCurrent", { bg = "#456268", fg = "#D0E8F2" })
      vim.api.nvim_set_hl(0, "FlashLabel", { bg = "#A25772", fg = "#EEF5FF" })
      require("flash").setup(opts)
    end,
  },
}
