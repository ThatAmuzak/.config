-- Keymaps are automatically loaded before lazy.nvim startup
-- Default LazyVim keymaps: https://lazyvim.github.io/configuration/keymaps
-- Add any additional keymaps here, or override defaults.
-- To override a LazyVim default, set it here (this runs after defaults are applied).

local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Save file(s): write all modified buffers, skip terminals
map("n", "<leader>ww", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buftype ~= "terminal"
      and vim.bo[buf].modifiable
      and vim.bo[buf].modified
    then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent write")
      end)
    end
  end
end, { desc = "Save file(s)" })

-- Save all and quit (overrides LazyVim session-quit default)
map("n", "<leader>qq", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      if vim.bo[buf].buftype == "terminal" then
        vim.cmd("bd! " .. buf)
      elseif vim.bo[buf].modifiable and vim.bo[buf].modified then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent write")
        end)
      end
    end
  end
  vim.cmd("qa")
end, { desc = "Save all and quit" })

-- Move by visual line
map("n", "j", "gj", { desc = "Move visual line down" })
map("n", "k", "gk", { desc = "Move visual line up" })
map("v", "j", "gj", { desc = "Move visual line down" })
map("v", "k", "gk", { desc = "Move visual line up" })

-- Delete character without yanking
map("n", "x", '"_x', { desc = "Delete character without yanking" })

-- Scrolling with cursor centered
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })
map("n", "G", "Gzzzv", { desc = "End of file centered" })

-- Editing
map("n", "d;", "d$", { desc = "Delete until end of line" })
map("n", "<leader>nl", "o<Esc>k", { desc = "Enter newline below" })
map("n", "<leader>NL", "O<Esc>j", { desc = "Enter newline above" })
map("n", "<leader>a", "ggVG", { desc = "Select all lines" })
map("n", "<leader>i", "gg=G", { desc = "Indent all lines" })

-- Window resizing
map("n", "<Up>", ":resize -2<CR>", { desc = "Resize window up" })
map("n", "<Down>", ":resize +2<CR>", { desc = "Resize window down" })
map("n", "<Left>", ":vertical resize -2<CR>", { desc = "Resize window left" })
map("n", "<Right>", ":vertical resize +2<CR>", { desc = "Resize window right" })

-- Indentation in visual mode
map("v", "<", "<gv", { desc = "Indent left and stay selected" })
map("v", ">", ">gv", { desc = "Indent right and stay selected" })
map("v", "p", '"_dP', { desc = "Paste without overwriting register" })

-- Window management (LazyVim default already handles <C-h/j/k/l>; kept for clarity)
map("n", "<leader>v", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>h", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>xs", ":close<CR>", { desc = "Close current split" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
