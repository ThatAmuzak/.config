return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	config = function()
		require("no-neck-pain").setup({
			killAllBuffersOnDisable = true,
			width = 125,
		})
	end,
}
