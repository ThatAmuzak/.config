-- Disable the Snacks explorer (replaced by oil) and free up its keymaps.
-- See: https://github.com/LazyVim/LazyVim/discussions/6100
return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false },
    },
    keys = {
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>e", false },
      { "<leader>E", false },
    },
  },
  {
    "stevearc/oil.nvim",
    dependencies = {
      {
        "nvim-mini/mini.icons",
        opts = {
          extension = {
            ["norg"] = { glyph = "󰧑", hl = "MiniIconsBlue" },
          },
        },
      },
    },
    -- Lazy loading is not recommended for oil
    lazy = false,
    keys = {
      { "<leader>e", "<Cmd>Oil<CR>", desc = "Oil: open parent directory" },
    },
    opts = {
      columns = { "icon", "default_file" },
      default_file = " ",
      keymaps = {
        ["<BS>"] = "actions.parent",
        ["-"] = false,
        ["<C-h>"] = false,
        ["<C-l>"] = false,
      },
      win_options = {
        winbar = "%!v:lua.get_oil_winbar()",
      },
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
    },
    config = function(_, opts)
      function _G.get_oil_winbar()
        local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
        local dir = require("oil").get_current_dir(bufnr)
        if dir then
          return vim.fn.fnamemodify(dir, ":~")
        else
          -- If there is no current directory (e.g. over ssh), just show the buffer name
          return vim.api.nvim_buf_get_name(0)
        end
      end
      require("oil").setup(opts)
    end,
  },
}
