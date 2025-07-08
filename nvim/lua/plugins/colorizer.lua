return {
	"norcalli/nvim-colorizer.lua",
	config = function()
		require("colorizer").setup({
			"css",
			"scss",
			"html",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"markdown",
			"org",
		})
	end,
}
