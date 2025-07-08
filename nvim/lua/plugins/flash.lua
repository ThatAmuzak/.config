local function setupCustomHighlightGroup()
	vim.api.nvim_command("hi clear FlashMatch")
	vim.api.nvim_command("hi clear FlashCurrent")
	vim.api.nvim_command("hi clear FlashLabel")

	vim.api.nvim_command("hi FlashMatch guibg=#4A47A3 guifg=#B8B5FF")
	vim.api.nvim_command("hi FlashCurrent guibg=#456268 guifg=#D0E8F2")
	vim.api.nvim_command("hi FlashLabel guibg=#A25772 guifg=#EEF5FF")
end

return {
	"folke/flash.nvim",
	event = "VeryLazy",
	---@type Flash.Config
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
	},
	modes = {
		char = {
			enabled = false,
		},
	},
	keys = {
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
	config = function()
		require("flash").setup({
			setupCustomHighlightGroup(),
			modes = {
				char = {
					enabled = false,
				},
			},
		})
	end,
}
