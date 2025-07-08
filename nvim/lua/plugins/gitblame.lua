return {
	"f-person/git-blame.nvim",
	event = "VeryLazy",
	opts = {
		enabled = true,
		message_template = " <summary> • <date> • <author> • <<sha>>",
		date_format = "%m-%d-%Y %H:%M:%S",
	},
	config = function()
		require("gitblame").setup({
			enabled = false,
		})
	end,
	vim.keymap.set("n", "<leader>gb", "<cmd>GitBlameToggle<CR>"),
}
