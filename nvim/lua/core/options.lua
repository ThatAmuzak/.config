vim.wo.number = true
vim.o.relativenumber = true
vim.o.clipboard = "unnamedplus"
vim.o.mouse = "a"
vim.o.autoindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.scrolloff = 10
vim.o.showtabline = 0
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.smartindent = true
vim.wo.signcolumn = "yes"
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})
vim.opt.shell = "pwsh"
vim.opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
vim.opt.termguicolors = true
vim.opt.conceallevel = 2
vim.opt.concealcursor = ""
vim.opt.linebreak = true
vim.g.sqlite_clib_path = vim.fn.expand("~\\Frameworks\\sqlite\\sqlite3.dll")
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.api.nvim_create_user_command("CdToGitRoot", function()
	local filepath = vim.fn.expand("%:p")
	local dir = vim.fn.fnamemodify(filepath, ":h")

	while dir ~= "/" do
		if vim.fn.isdirectory(dir .. "/.git") == 1 then
			vim.cmd("cd " .. dir)
			print("Changed directory to git root: " .. dir)
			return
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end

	-- fallback to file's directory
	local fallback = vim.fn.fnamemodify(filepath, ":h")
	vim.cmd("cd " .. fallback)
	print("No git root found. Changed directory to file location: " .. fallback)
end, {})

vim.api.nvim_create_user_command("CdToCurrentDirectory", function()
	local filepath = vim.fn.expand("%:p")
	local dir = vim.fn.fnamemodify(filepath, ":h")

	vim.cmd("cd " .. dir)
	print("Changed directory to file location: " .. dir)
end, {})

function ToggleSpell()
	vim.wo.spell = not vim.wo.spell
end
vim.api.nvim_create_user_command("ToggleSpell", ToggleSpell, {})
vim.api.nvim_create_user_command("SpellToggle", ToggleSpell, {}) -- cuz I keep forgetting which word is first lmao
