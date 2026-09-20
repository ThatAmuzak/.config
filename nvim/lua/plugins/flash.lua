-- Rebind <leader>ff to flash's on-screen search/jump
return {
  {
    "folke/flash.nvim",
    keys = {
      {
        "<leader>ff",
        function()
          require("flash").jump()
        end,
        desc = "Flash Search (on-screen jump)",
      },
    },
  },
}
