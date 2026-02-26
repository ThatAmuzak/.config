return {
	{
		"guns/vim-sexp",
		event = "VeryLazy",
	},
	{
		"tpope/vim-sexp-mappings-for-regular-people",
		event = "VeryLazy",
		dependencies = { "guns/vim-sexp" },
		init = function() end,
	},
}
