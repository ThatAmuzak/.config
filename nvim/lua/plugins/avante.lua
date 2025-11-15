return {
	"yetone/avante.nvim",
	build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		or "make",
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	---@module 'avante'
	---@type avante.Config
	opts = {
		-- add any opts here
		-- this file can contain specific instructions for your project
		instructions_file = "avante.md",
		-- for example
		provider = "openai",
		mode = "legacy",
		providers = {
			openai = {
				endpoint = "https://api.openai.com/v1", -- LLM API endpoint
				api_key = "OPENAI_API_KEY", -- Environment variable name for the LLM API key
				model = "gpt-5-mini", -- LLM model name
				timeout = 30000,
				extra_request_body = {
					temperature = 0.75,
					max_completion_tokens = 16384,
				},
			},
		},
		mappings = {
			new_ask = "<Leader>ua",
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
		shortcuts = {
			{
				name = "Summarize",
				description = "Summarize research paper",
				details = "Summarize a research paper quickly",
				prompt = "Read the contents of the provided text file, which contains a research paper. Summarize the paper in a clear, high-level manner, highlighting the main objectives, methods, and results. Format the summary in an org format. Have a single Summary second level header, with one fourth level header for Goal, one for Method, and one for Results. Subpointers are fine, but keep it short, easy to read and easy to understand. Apply the summary output as a modification with a search and replace to the end of the currently open buffer norg file.",
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"nvim-mini/mini.pick", -- for file_selector provider mini.pick
		"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
		"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
		"ibhagwan/fzf-lua", -- for file_selector provider fzf
		"stevearc/dressing.nvim", -- for input provider dressing
		"folke/snacks.nvim", -- for input provider snacks
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
}
