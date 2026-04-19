local M = vim.keymap.set

local function clamp(value, min_value, max_value)
	return math.max(min_value, math.min(value, max_value))
end

local function normalize_visible_line(lnum)
	local fold_start = vim.fn.foldclosed(lnum)
	if fold_start ~= -1 then
		return fold_start
	end

	return lnum
end

local function next_visible_line(lnum, last_line)
	if lnum >= last_line then
		return last_line
	end

	local fold_end = vim.fn.foldclosedend(lnum)
	if fold_end ~= -1 then
		return math.min(fold_end + 1, last_line)
	end

	local next_line = lnum + 1
	local next_fold_start = vim.fn.foldclosed(next_line)
	if next_fold_start ~= -1 then
		return next_fold_start
	end

	return next_line
end

local function prev_visible_line(lnum)
	if lnum <= 1 then
		return 1
	end

	local fold_start = vim.fn.foldclosed(lnum)
	if fold_start ~= -1 then
		return math.max(fold_start - 1, 1)
	end

	local prev_line = lnum - 1
	local prev_fold_start = vim.fn.foldclosed(prev_line)
	if prev_fold_start ~= -1 then
		return prev_fold_start
	end

	return prev_line
end

local function move_visible_lines(start_line, steps, last_line)
	local line = normalize_visible_line(clamp(start_line, 1, last_line))

	if steps > 0 then
		for _ = 1, steps do
			local next_line = next_visible_line(line, last_line)
			if next_line == line then
				break
			end
			line = next_line
		end
	elseif steps < 0 then
		for _ = 1, math.abs(steps) do
			local prev_line = prev_visible_line(line)
			if prev_line == line then
				break
			end
			line = prev_line
		end
	end

	return line
end

local function centered_half_page(direction)
	local win = vim.api.nvim_get_current_win()
	local last_line = vim.api.nvim_buf_line_count(0)
	local height = vim.api.nvim_win_get_height(win)
	local page_size = math.max(1, math.floor(height / 2))
	local center_offset = math.max(0, math.floor((height - 1) / 2))
	local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
	local target_line = move_visible_lines(cursor_line, direction * page_size, last_line)
	local target_topline = move_visible_lines(target_line, -center_offset, last_line)
	local view = vim.fn.winsaveview()

	view.lnum = target_line
	view.topline = target_topline

	vim.fn.winrestview(view)
end

M("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
M("n", "<leader>-", "<cmd>split<cr>", { desc = "Split window horizontally" })
M("v", "<C-h>", "<C-w>h", { desc = "Move to left window" })
M("v", "<C-j>", "<C-w>j", { desc = "Move to below window" })
M("v", "<C-k>", "<C-w>k", { desc = "Move to above window" })
M("v", "<C-l>", "<C-w>l", { desc = "Move to right window" })
M("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close window" })
M("n", "<C-Up>", ":resize +2<CR>", { noremap = true, silent = true, desc = "Increase height" })
M("n", "<C-Down>", ":resize -2<CR>", { noremap = true, silent = true, desc = "Decrease height" })
M("n", "<C-,>", ":vertical resize -2<CR>", { noremap = true, silent = true, desc = "Increase width" })
M("n", "<C-.>", ":vertical resize +2<CR>", { noremap = true, silent = true, desc = "Decrease width" })
M("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
-- M("n", "<C-a>", 'mzggVG"+y`zzz', { desc = "Copy whole file" })
M("n", "J", "mzJ`z", { desc = "Merge bottom line" })
M("n", "<C-u>", function()
	centered_half_page(-1)
end, { silent = true, desc = "Scroll up and center cursor" })
M("n", "<C-d>", function()
	centered_half_page(1)
end, { silent = true, desc = "Scroll down and center cursor" })

M("n", "<esc><esc>", ":noh<CR>", { silent = true, nowait = true })
M("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
M("n", "j", "gj", { desc = "Move down" })
M("n", "k", "gk", { desc = "Move down" })
M("n", "<leader>cr", function()
	vim.lsp.buf.rename()
end, {})

-- Copy file paths
M("n", "<leader>xp", function()
	local file_path = vim.fn.expand("%")
	vim.fn.setreg("+", file_path)
	print("Copied file path: " .. file_path)
end, { desc = "Copy file path" })

local function toggle_diagnostics_virtual_text()
	local new_config = not vim.diagnostic.config().virtual_text
	vim.diagnostic.config({
		virtual_text = new_config,
	})
end

M("n", "<leader>d", toggle_diagnostics_virtual_text, { desc = "Toggle diagnostics" })

-- LSP configs
M("n", "K", function()
	vim.lsp.buf.hover()
end, { desc = "Hover doc" })

M("n", "<leader>ca", function()
	vim.lsp.buf.code_action()
end, { desc = "Hover doc" })

M("n", "<leader>bd", ":bp<bar>sp<bar>bn<bar>bd<CR>")

-- Tabs
M("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New tab" })
M("n", "<leader>tx", "<cmd>tabclose<cr>", { desc = "Close tab" })

M("n", "<leader>1", "1gt", { desc = "Go to tab 1" })
M("n", "<leader>2", "2gt", { desc = "Go to tab 2" })
M("n", "<leader>3", "3gt", { desc = "Go to tab 3" })
M("n", "<leader>4", "4gt", { desc = "Go to tab 4" })
M("n", "<leader>5", "5gt", { desc = "Go to tab 5" })
M("n", "<leader>6", "6gt", { desc = "Go to tab 6" })
M("n", "<leader>7", "7gt", { desc = "Go to tab 7" })
M("n", "<leader>8", "8gt", { desc = "Go to tab 8" })
M("n", "<leader>9", "9gt", { desc = "Go to tab 9" })
M("n", "<leader>0", "10gt", { desc = "Go to tab 10" })

M("n", "[t", ":tabprevious<CR>", { desc = "Previous tab" })
M("n", "]t", ":tabnext<CR>", { desc = "Next tab" })

-- escape from terminal mode
M("t", "<C-Space>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

-- keymaps for creating terminals similar to tmux splits, using Ctrl-b as prefix
M("n", "<C-Space>|", "<cmd>vsplit | terminal<cr>i", { desc = "Vertical terminal" })
M("n", "<C-Space>-", "<cmd>split | terminal<cr>i", { desc = "Horizontal terminal" })
M("n", "<C-Space>t", "<cmd>terminal<cr>i", { desc = "Open terminal" })
