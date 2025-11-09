local vim = vim

local config = {
	python = "python",
	script = vim.fn.expand("~/.config/nvim/lua/plugins/utils/pdf_to_txt.py"),
	parent = vim.fn.expand("~/Notes/Brain2/papers"),
	skip_existing = true,
}

local function notify(msg, level)
	level = level or vim.log.levels.INFO
	vim.schedule(function()
		vim.notify(msg, level, { title = "pdf2txt" })
	end)
end

local function validate()
	if not config.script or config.script == "" then
		notify("Missing python script path in config (script)", vim.log.levels.ERROR)
		return false
	end
	if not config.parent or config.parent == "" then
		notify("Missing parent directory path in config (parent)", vim.log.levels.ERROR)
		return false
	end
	-- quick fs checks
	local s_script = vim.loop.fs_stat(config.script)
	if not s_script or s_script.type ~= "file" then
		notify("Python script not found: " .. tostring(config.script), vim.log.levels.ERROR)
		return false
	end
	local s_parent = vim.loop.fs_stat(config.parent)
	if not s_parent or s_parent.type ~= "directory" then
		notify("Parent directory not found: " .. tostring(config.parent), vim.log.levels.ERROR)
		return false
	end
	return true
end

local function run(force_skip)
	notify("TXT conversions started", vim.log.levels.INFO)

	if not validate() then
		return
	end

	local args = { config.script, config.parent }
	local use_skip = nil
	if type(force_skip) == "boolean" then
		use_skip = force_skip
	else
		use_skip = config.skip_existing
	end
	if use_skip then
		table.insert(args, "--skip-existing")
	end

	local cmd = { config.python }
	for _, a in ipairs(args) do
		table.insert(cmd, a)
	end

	local jid = vim.fn.jobstart(cmd, {
		detach = true,
		on_exit = function(_, code, _)
			vim.schedule(function()
				if code == 0 then
					notify("TXT conversions complete", vim.log.levels.INFO)
				else
					notify("Conversion process exited with code: " .. tostring(code), vim.log.levels.ERROR)
				end
			end)
		end,
	})

	if not jid or jid <= 0 then
		notify("Failed to start conversion job", vim.log.levels.ERROR)
	end
end

vim.api.nvim_create_user_command("PdfToText", function()
	run()
end, {})
vim.api.nvim_create_user_command("PdfToTextForce", function()
	run(false)
end, {})

vim.keymap.set("n", "<leader>npt", "<cmd>PdfToText<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>npft", "<cmd>PdfToTextForce<CR>", { noremap = true, silent = true })
