return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts

	opts = {},
	-- Optional dependencies
	dependencies = {
		{
			"echasnovski/mini.icons",
			opts = {
				extension = {
					["norg"] = { glyph = "󰧑", hl = "MiniIconsBlue" },
				},
			},
		},
	},
	-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
	vim.keymap.set("n", "<leader>e", "<Cmd>Oil<CR>"),
	config = function()
		function _G.get_oil_winbar()
			local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
			local dir = require("oil").get_current_dir(bufnr)
			if dir then
				return vim.fn.fnamemodify(dir, ":~")
			else
				-- If there is no current directory (e.g. over ssh), just show the buffer name
				return vim.api.nvim_buf_get_name(0)
			end
		end
		require("oil").setup({
			columns = { "icon", default_file = " " },
			keymaps = {
				["<BS>"] = "actions.parent",
				["-"] = false,
				["<C-h>"] = false,
				["<C-l>"] = false,
			},
			win_options = {
				winbar = "%!v:lua.get_oil_winbar()",
			},
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
			},
		})
	end,
}
