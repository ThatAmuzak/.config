-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Guarantee `nvim` (no args) always lands on the dashboard, even when Snacks'
-- own startup-check bails (e.g. the first buffer is flagged modified or its
-- state isn't pristine). `nvim <file>` is untouched and opens the file normally.
vim.api.nvim_create_autocmd("VimEnter", {
  nested = true,
  callback = function()
    -- Only for a plain `nvim` with no file arguments.
    if vim.fn.argc(-1) ~= 0 then
      return
    end
    local buf = vim.api.nvim_get_current_buf()
    -- Already on the dashboard (LazyVim opened it): leave it alone.
    if vim.bo[buf].filetype == "snacks_dashboard" then
      return
    end
    -- Let LazyVim/Snacks attempt its own startup open first, then fill in if it
    -- did not (so we never double-open).
    vim.defer_fn(function()
      if not pcall(require, "snacks") then
        return
      end
      local b = vim.api.nvim_get_current_buf()
      if vim.bo[b].filetype == "snacks_dashboard" then
        return
      end
      local empty = vim.api.nvim_buf_line_count(b) <= 1
        and #(vim.api.nvim_buf_get_lines(b, 0, 1, false)[1] or "") == 0
      if empty and vim.api.nvim_buf_get_name(b) == "" and vim.bo[b].buftype == "" then
        pcall(Snacks.dashboard.open, { buf = b, win = vim.api.nvim_get_current_win() })
      end
    end, 50)
  end,
})

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
