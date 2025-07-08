-- Inspired from https://www.youtube.com/watch?v=5PIiKDES_wc

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.9)
	local height = opts.height or math.floor(vim.o.lines * 0.9)

	local col = math.floor((vim.o.columns - width) / 2)
	local cmdheight = vim.api.nvim_get_option("cmdheight")
	local row = math.floor((vim.o.lines - cmdheight - height) / 2)

	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return { buf = buf, win = win }
end

local toggle_terminal = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({ buf = state.floating.buf })
		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.terminal()
		end
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

vim.api.nvim_create_user_command("Terminal", toggle_terminal, {})
vim.keymap.set("n", "<C-_>", "<cmd>Terminal<CR>", { noremap = true, silent = true })

vim.api.nvim_create_autocmd("ExitPre", {
	callback = function()
		if vim.api.nvim_buf_is_valid(state.floating.buf) then
			local chan = vim.b[state.floating.buf].terminal_job_id
			if chan then
				vim.fn.jobstop(chan)
			end
		end
	end,
})
