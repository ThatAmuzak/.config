return {
	"goolord/alpha-nvim",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		local header = {
			type = "text",
			val = {
				[[                                                                     ]],
				[[       ████ ██████           █████      ██                     ]],
				[[      ███████████             █████                             ]],
				[[      █████████ ███████████████████ ███   ███████████   ]],
				[[     █████████  ███    █████████████ █████ ██████████████   ]],
				[[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
				[[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
				[[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
			},
			opts = { position = "center", hl = "AlphaHeader" },
		}

		local main_buttons = {
			type = "group",
			val = {
				dashboard.button("f", "󰮗  Find File", ":Telescope find_files <CR>"),
				dashboard.button("n", "  New File", ":enew<CR>"),
				dashboard.button("e", "󰙅  Open Oil", "<Cmd>Oil<CR>"),
			},
			opts = { spacing = 1 },
		}

		dashboard.config.layout = {
			{ type = "padding", val = 4 },
			header,
			{ type = "padding", val = 2 },
			main_buttons,
		}

		dashboard.section.header = nil
		dashboard.section.buttons = nil

		vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#2BC6FF", bold = true })
		alpha.setup(dashboard.opts)

		vim.keymap.set("n", "<leader>A", function()
			vim.cmd("Alpha")
		end, { desc = "Launch Alpha" })
	end,
}
