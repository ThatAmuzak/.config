return {
	"cappyzawa/trim.nvim",
	opts = {},
	config = function()
		require("trim").setup({
			-- if you want to ignore markdown file.
			-- you can specify filetypes.
			ft_blocklist = { "markdown" },

			-- if you want to remove multiple blank lines
			patterns = {
				[[%s/\(\n\n\)\n\+/\1/]], -- replace multiple blank lines with a single line
			},

			-- if you want to disable trim on write by default
			trim_on_write = false,

			-- highlight trailing spaces
			highlight = false,
		})
	end,
}
