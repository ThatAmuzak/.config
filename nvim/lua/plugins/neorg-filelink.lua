-- Place this in your Neovim config (e.g. init.lua or plugins.lua)
local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

-- Cache setup
local norg_cache = nil
local function build_norg_cache()
	local cwd = vim.fn.getcwd()
	local handle = io.popen('rg --files --glob="*.norg" -g "!~/.git/*"')
	local result = handle:read("*a")
	handle:close()
	local lines = {}
	for path in result:gmatch("[^\r\n]+") do
		table.insert(lines, path)
	end
	norg_cache = lines
end

-- Picker function
function _G.telescope_neorg_insert_link()
	if not norg_cache then
		build_norg_cache()
	end

	pickers
		.new({}, {
			prompt_title = "Neorg .norg files",
			finder = finders.new_table({ results = norg_cache }),
			previewer = false,
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local sel = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					local rel = sel.value
					local filename = vim.fn.fnamemodify(rel, ":t:r")
					local link = string.format("{:$/%s:}[%s] ", rel, filename)
					vim.api.nvim_put({ link }, "c", true, true)
					vim.schedule(function()
						vim.api.nvim_feedkeys("i", "n", false)
					end)
				end)
				return true
			end,
		})
		:find()
end

-- Keybind (adjust as desired)
vim.keymap.set("n", "<leader>nif", _G.telescope_neorg_insert_link, { desc = "Neorg: insert .norg file link" })
vim.keymap.set("i", "<C-f>", _G.telescope_neorg_insert_link, { desc = "Neorg: insert .norg file link" })

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.norg",
	callback = function()
		if not norg_cache then
			build_norg_cache()
		end
	end,
})
