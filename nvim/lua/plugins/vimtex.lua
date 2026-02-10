return {
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.cmd("syntax enable")
			vim.cmd("let g:vimtex_view_general_viewer='sioyek'")
			-- %1: file, %2: line number
			local options = string.format(
				'--reuse-window --inverse-search="nvr --servername %s +%%2 %%1" --forward-search-file @tex --forward-search-line @line @pdf',
				vim.v.servername
			)

			local command = string.format("let g:vimtex_view_general_options='%s'", options)
			vim.cmd(command)
			vim.cmd("let g:vimtex_compiler_progname='nvr'")
		end,
	},

	{
		"micangl/cmp-vimtex",
	},
}
