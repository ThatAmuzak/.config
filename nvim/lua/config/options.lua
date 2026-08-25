-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Tabs & indentation (user prefers 4 spaces)
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Cursor & line wrapping
opt.scrolloff = 10
opt.linebreak = true

-- Split behavior
opt.splitbelow = true
opt.splitright = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.showtabline = 0

-- Conceal
opt.conceallevel = 2
opt.concealcursor = ""

-- Mouse & clipboard
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Spelling
opt.spell = true
opt.spelllang = "en_us"

-- Windows/PowerShell shell (Windows-native config)
opt.shell = "pwsh"
opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
opt.shellquote = ""
opt.shellxquote = ""
