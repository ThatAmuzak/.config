return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	opts = {
		transparent_background = true,
		term_colors = true,
	},
	config = function()
		require("catppuccin").setup({
			no_italic = false,
		})
		vim.cmd.colorscheme("catppuccin")
		vim.cmd([[
		  highlight Normal       guibg=NONE ctermbg=NONE
		  highlight NonText      guibg=NONE ctermbg=NONE
		  highlight SignColumn   guibg=NONE ctermbg=NONE
		]])
	end,
}
