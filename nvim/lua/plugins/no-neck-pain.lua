return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	config = function()
		require("no-neck-pain").setup({
			killAllBuffersOnDisable = true,
			width = 125,
		})
		vim.keymap.set("n", "<C-n>", function()
			vim.cmd("NoNeckPain")
		end, { desc = "Toggle No‑Neck‑Pain" })
	end,
}
