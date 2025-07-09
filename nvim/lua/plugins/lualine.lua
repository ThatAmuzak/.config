return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({
				override_by_extension = {
					["norg"] = {
						icon = "󰧑",
						color = "#89B4FA",
						name = "norg",
					},
				},
			})
		end,
	},
	config = function()
		require("lualine").setup({
			options = { theme = "powerline_dark" },
			sections = {
				lualine_c = {
					{
						"filename",
						path = 1,
					},
				},
			},
		})
	end,
}
