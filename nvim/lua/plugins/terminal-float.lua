return {
  {
    "folke/snacks.nvim",
    opts = function()
      -- Opaque border for the terminal float, while the terminal interior stays
      -- transparent/see-through. Sampled from the active colorscheme.
      local function set_border_hl()
        vim.api.nvim_set_hl(0, "SnacksTerminalBorder", {
          fg = vim.api.nvim_get_hl(0, { name = "FloatBorder" }).fg or "#ffffff",
          bg = vim.api.nvim_get_hl(0, { name = "FloatBorder" }).bg
            or vim.api.nvim_get_hl(0, { name = "NormalFloat" }).bg
            or "#1e1e2e",
        })
      end
      set_border_hl()
      -- Recreate it if the colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("SnacksTerminalBorder", { clear = true }),
        callback = set_border_hl,
      })

      -- Open the terminal in a focused floating ("hover") window at ~90% of the
      -- screen, wrapped in an opaque border. The interior keeps its transparent bg.
      return {
        terminal = {
          win = {
            style = "float",
            position = "float",
            width = 0.9,
            height = 0.9,
            border = "rounded",
            backdrop = false,
            wo = {
              winhighlight = "Normal:SnacksNormal,NormalNC:SnacksNormalNC,WinBar:SnacksWinBar,WinBarNC:SnacksWinBarNC,FloatTitle:SnacksTitle,FloatFooter:SnacksFooter,WinSeparator:SnacksWinSeparator,FloatBorder:SnacksTerminalBorder",
            },
          },
        },
      }
    end,
  },
}