return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = {
			provider = "openai",
			openai = {
				endpoint = "https://api.openai.com/v1",
				model = "gpt-4.1-mini", -- your desired model (or use gpt-4o, etc.)
				timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
				temperature = 0,
				max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
				--reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
			},
			mappings = {
				ask = "<Leader>ua",
				edit = "<Leader>ue",
				refresh = "<Leader>ur",
				focus = "<Leader>uf",
				toggle = {
					default = "<Leader>uu",
					debug = "<Leader>ud",
					hint = "<Leader>uh",
					suggestion = "<Leader>us",
					repomap = "<Leader>uR",
				},
				stop = "<Leader>ux",
				select_history = "<Leader>uH",
				files = {
					add_current = "<leader>uc", -- Add current buffer to selected files
					add_all_buffers = "<leader>uB", -- Add all buffer files to selected files
				},
				select_model = "<Leader>u?",
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		-- build = "make",
		build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false", -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
}
