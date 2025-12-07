return {
	"yetone/avante.nvim",
	build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		or "make",
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	---@module 'avante'
	---@type avante.Config
	opts = {
		instructions_file = "avante.md",
		mode = "legacy",
		provider = "gemini",
		providers = {
			gemini = {
				endpoint = "https://generativelanguage.googleapis.com/v1beta", -- Gemini API endpoint
				api_key = "AVANTE_GEMINI_API_KEY", -- Environment variable name
				model = "models/gemini-2.5-flash", -- Gemini model name
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
				prompt = "Read the contents of the provided text file, which contains a research paper. Summarize the paper in a clear, high-level manner, highlighting the main objectives, methods, and results. Format the summary in neovim's norg format, similar to emacs org mode. Have a single Summary second level header (two stars and a space), with one fourth level header (4 stars and a space) for Goal, one for Method, and one for Results. Subpointers are fine, but keep it short, easy to read and easy to understand. Apply the summary output as a modification with a search and replace to the end of the currently open buffer norg file. Keep the formatting light. For formatting, bold is a single pair of stars around the content, italacs is a single pair of forward slashes, and underline is a single pair of underscores. A bullet point is a hyphen and a numeric point is a tilde. Nesting pointers is just adding more of those symbols so two hyphens for a nested bullet point.",
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
