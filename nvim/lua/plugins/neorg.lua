return {
	"nvim-neorg/neorg",
	lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
	version = "*", -- Pin Neorg to the latest stable release
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("neorg").setup({

			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/Notes/Brain2/",
						},
						default_workspace = "notes",
					},
				},
				["core.completion"] = { config = { engine = "nvim-cmp" }, name = "[Neorg]" },
				["core.integrations.nvim-cmp"] = {},
			},
			vim.keymap.set("n", "<leader>ntt", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", { desc = "Cycle Task" }),
			vim.keymap.set(
				"n",
				"<leader>nta",
				"<Plug>(neorg.qol.todo-items.todo.task-ambiguous)",
				{ desc = "Mark Task Ambiguous" }
			),
			vim.keymap.set(
				"n",
				"<leader>ntd",
				"<Plug>(neorg.qol.todo-items.todo.task-done)",
				{ desc = "Mark Task Done" }
			),
			vim.keymap.set(
				"n",
				"<leader>nth",
				"<Plug>(neorg.qol.todo-items.todo.task-on-hold)",
				{ desc = "Mark Task On Hold" }
			),
			vim.keymap.set(
				"n",
				"<leader>nti",
				"<Plug>(neorg.qol.todo-items.todo.task-important)",
				{ desc = "Mark Task Important" }
			),
			vim.keymap.set(
				"n",
				"<leader>ntp",
				"<Plug>(neorg.qol.todo-items.todo.task-pending)",
				{ desc = "Mark Task Pending" }
			),
			vim.keymap.set(
				"n",
				"<leader>ntr",
				"<Plug>(neorg.qol.todo-items.todo.task-recurring)",
				{ desc = "Mark Task Recurring" }
			),
			vim.keymap.set(
				"n",
				"<leader>ntu",
				"<Plug>(neorg.qol.todo-items.todo.task-undone)",
				{ desc = "Mark Task Undone" }
			),
			vim.keymap.set("n", "<leader>nid", "<Plug>(neorg.tempus.insert-date)", { desc = "Insert Date" }),
			vim.keymap.set("i", "<C-d>", "<Esc><Plug>(neorg.tempus.insert-date)", { desc = "Insert Date" }),
			vim.keymap.set("i", "<C-j>", function()
				-- break undo sequence
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>u", true, false, true), "n", false)
				-- insert new line with checklist
				vim.api.nvim_feedkeys("\n- ( ) ", "n", false)
				-- break undo sequence again so undo stops here
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-g>u", true, false, true), "n", false)
			end),
			vim.keymap.set("n", "<leader>nsf", function()
				local file_name = vim.fn.expand("%:t")
				require("telescope").extensions.live_grep_args.live_grep_args({
					default_text = file_name,
				})
			end, { desc = "Search for file references in notes" }),
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "norg",
			callback = function()
				vim.opt_local.spell = false
			end,
		})
	end,
}
