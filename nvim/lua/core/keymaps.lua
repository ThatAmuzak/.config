vim.g.mapleader = " "
vim.g.maplocalleader = " l"
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

local base_opts = { noremap = true, silent = true }

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", base_opts, { desc = desc }))
end

-- Save and quit
map("n", "<leader>ww", "<cmd> wa <CR>", "Save file")
map("n", "<leader>qq", "<cmd> wqa <CR>", "Save all and quit")

-- Editing enhancements
map("n", "j", "gj", "Move visual line down")
map("n", "k", "gk", "Move visual line up")
map("v", "j", "gj", "Move visual line down")
map("v", "k", "gk", "Move visual line up")
map("n", "x", '"_x', "Delete character without yanking")
map("n", "<C-d>", "<C-d>zz", "Scroll down and center")
map("n", "<C-u>", "<C-u>zz", "Scroll up and center")
map("n", "n", "nzzzv", "Next search result centered")
map("n", "N", "Nzzzv", "Previous search result centered")
map("n", "G", "Gzzzv", "End of file centered")
map("n", "d;", "d$", "Delete until end of line")
map("n", "<leader>nl", "o<Esc>k", "Enter newline below")
map("n", "<leader>NL", "O<Esc>j", "Enter newline above")
map("n", "<leader>a", "ggVG", "Select all lines")
map("n", "<leader>i", "gg=G", "Indent all lines")

-- Window resizing
map("n", "<Up>", ":resize -2<CR>", "Resize window up")
map("n", "<Down>", ":resize +2<CR>", "Resize window down")
map("n", "<Left>", ":vertical resize -2<CR>", "Resize window left")
map("n", "<Right>", ":vertical resize +2<CR>", "Resize window right")

-- Indentation in visual mode
map("v", "<", "<gv", "Indent left and stay selected")
map("v", ">", ">gv", "Indent right and stay selected")
map("v", "p", '"_dP', "Paste without overwriting register")

-- LSP hover
map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", "LSP Hover")
map("n", "E", vim.diagnostic.open_float, "Show Error on Line")

-- Window management
map("n", "<leader>v", "<C-w>v", "Split window vertically")
map("n", "<leader>h", "<C-w>s", "Split window horizontally")
map("n", "<leader>se", "<C-w>=", "Make splits equal size")
map("n", "<leader>xs", ":close<CR>", "Close current split")
map("n", "<C-k>", ":wincmd k<CR>", "Move to window above")
map("n", "<C-j>", ":wincmd j<CR>", "Move to window below")
map("n", "<C-h>", ":wincmd h<CR>", "Move to window left")
map("n", "<C-l>", ":wincmd l<CR>", "Move to window right")

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

map("n", "<leader>sif", function()
	vim.fn.setreg("/", "\\<" .. vim.fn.expand("<cword>") .. "\\>")
	vim.cmd("normal! n")
end, "Search word under cursor")

map("v", "<leader>sif", function()
	local saved_reg = vim.fn.getreg('"')
	vim.cmd('normal! "vy') -- yank visual selection into "v
	local selection = vim.fn.getreg("v"):gsub("[\n\r]", "") -- get and clean it
	vim.fn.setreg("/", vim.fn.escape(selection, "\\/")) -- set search register
	vim.fn.setreg('"', saved_reg) -- restore unnamed register
	vim.cmd("normal! n")
end, "Search visual selection")

local function replace_visual_selection()
	local saved_reg = vim.fn.getreg('"')
	vim.cmd('normal! "vy')
	local sel = vim.fn.getreg("v"):gsub("[\n\r]", "")
	vim.fn.setreg('"', saved_reg)

	vim.ui.input({ prompt = ("Replace %q with: "):format(sel) }, function(input)
		if not input then
			return
		end

		local cmd = string.format("%%s/%s/%s/gc", vim.fn.escape(sel, "\\/"), input)
		vim.cmd(cmd)
	end)
end

vim.keymap.set("v", "<leader>rif", function()
	replace_visual_selection()
end, { desc = "Replace visual selection interactively" })
