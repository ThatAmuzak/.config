return {
	"tzachar/local-highlight.nvim",
	config = function()
		require("local-highlight").setup({
			disable_file_types = { "tex" },
			debounce_timeout = 0,
		})
	end,
}
