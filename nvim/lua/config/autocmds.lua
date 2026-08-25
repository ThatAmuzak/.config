-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

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

local function toggle_spell()
  vim.wo.spell = not vim.wo.spell
end
vim.api.nvim_create_user_command("ToggleSpell", toggle_spell, {})
vim.api.nvim_create_user_command("SpellToggle", toggle_spell, {})
