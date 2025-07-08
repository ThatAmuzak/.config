return {
	{
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.g.vimtex_view_general_viewer = "SumatraPDF"
			vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
			vim.g.vimtex_syntax_enabled = 1
			local function toggle_quickfix()
				local windows = vim.fn.getwininfo()
				if vim.g.vimtex_quickfix_mode == 0 then
					vim.g.vimtex_quickfix_mode = 2
					print("VimTeX: Showing errors and warnings")
					for _, win in pairs(windows) do
						if win["quickfix"] == 0 then
							vim.cmd("cclose")
						end
					end
				else
					vim.g.vimtex_quickfix_mode = 0
					print("VimTeX: Hiding error and warning console")
					for _, win in pairs(windows) do
						if win["quickfix"] == 1 then
							vim.cmd("cclose")
						end
					end
				end
			end

			vim.keymap.set("n", "<localleader>qf", toggle_quickfix, { desc = "Toggle Quickfix Window" })
		end,
	},

	{
		"micangl/cmp-vimtex",
	},
}
