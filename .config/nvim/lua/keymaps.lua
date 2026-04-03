local M = vim.keymap.set

local tmux_directions = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function tmux_navigate(key)
	vim.cmd("TmuxNavigate" .. tmux_directions[key])
end

local function terminal_tmux_navigate(key)
	vim.cmd("stopinsert")
	tmux_navigate(key)
end

local function scroll_half_page(direction)
	return function()
		local view = vim.fn.winsaveview()
		local win_height = vim.api.nvim_win_get_height(0)
		local half_page = math.max(1, math.floor(win_height / 2))
		local last_line = vim.api.nvim_buf_line_count(0)
		local target_line = math.max(1, math.min(last_line, view.lnum + (direction * half_page)))
		local target_text = vim.api.nvim_buf_get_lines(0, target_line - 1, target_line, false)[1] or ""
		local target_col = math.min(view.col, #target_text)
		local max_topline = math.max(1, last_line - win_height + 1)

		vim.api.nvim_win_set_cursor(0, { target_line, target_col })

		view = vim.fn.winsaveview()
		view.topline = math.max(1, math.min(target_line - math.floor(win_height / 2), max_topline))
		vim.fn.winrestview(view)

		if vim.fn.foldclosed(target_line) ~= -1 then
			vim.cmd("normal! zv")
		end
	end
end

M("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
M("n", "<leader>-", "<cmd>split<cr>", { desc = "Split window horizontally" })
M("n", "<C-h>", function() tmux_navigate("h") end, { desc = "Move to left split" })
M("n", "<C-j>", function() tmux_navigate("j") end, { desc = "Move to below split" })
M("n", "<C-k>", function() tmux_navigate("k") end, { desc = "Move to above split" })
M("n", "<C-l>", function() tmux_navigate("l") end, { desc = "Move to right split" })
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
M("n", "<C-u>", scroll_half_page(-1), { silent = true, desc = "Scroll up and center cursor" })
M("n", "<C-d>", scroll_half_page(1), { silent = true, desc = "Scroll down and center cursor" })

M("n", "<esc><esc>", ":noh<CR>", { silent = true, nowait = true })
M("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
M("n", "j", "gj", { desc = "Move down" })
M("n", "k", "gk", { desc = "Move down" })
M("n", "<leader>cr", vim.lsp.buf.rename, {})

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

M("n", "<leader>ca", function ()
  vim.lsp.buf.code_action()
end, { desc = "Hover doc" })

M("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
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

M("t", "<C-h>", function() terminal_tmux_navigate("h") end, { desc = "Move left" })
M("t", "<C-j>", function() terminal_tmux_navigate("j") end, { desc = "Move down" })
M("t", "<C-k>", function() terminal_tmux_navigate("k") end, { desc = "Move up" })
M("t", "<C-l>", function() terminal_tmux_navigate("l") end, { desc = "Move right" })

-- keymaps for creating terminals similar to tmux splits, using Ctrl-b as prefix
M("n", "<C-Space>|", "<cmd>vsplit | terminal<cr>i", { desc = "Vertical terminal" })
M("n", "<C-Space>-", "<cmd>split | terminal<cr>i", { desc = "Horizontal terminal" })
M("n", "<C-Space>t", "<cmd>terminal<cr>i", { desc = "Open terminal" })
