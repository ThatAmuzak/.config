return {
	"nvim-neorg/neorg",
	lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
	version = "*", -- Pin Neorg to the latest stable release
	dependencies = {
		"nvim-lua/plenary.nvim",
		"ThatAmuzak/neorg-telescope",
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
				["core.integrations.telescope"] = {},
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
			vim.keymap.set(
				"n",
				"<leader>nif",
				"<Plug>(neorg.telescope.insert_file_link)",
				{ desc = "Insert File Link" }
			),
			vim.keymap.set("n", "<leader>nil", "<Plug>(neorg.telescope.insert_link)", { desc = "Insert Linkable" }),
		})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = "norg",
			callback = function()
				vim.opt_local.spell = false
				require("no-neck-pain").enable()
			end,
		})
	end,
}
