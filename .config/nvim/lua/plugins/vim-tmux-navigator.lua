local packadd = require("plugins.util").packadd

local M = {
	name = "vim-tmux-navigator",
}

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

function M.setup()
	vim.g.tmux_navigator_no_mappings = 1
	packadd(M.name)

	vim.keymap.set("n", "<C-h>", function() tmux_navigate("h") end, { desc = "Move to left split" })
	vim.keymap.set("n", "<C-j>", function() tmux_navigate("j") end, { desc = "Move to below split" })
	vim.keymap.set("n", "<C-k>", function() tmux_navigate("k") end, { desc = "Move to above split" })
	vim.keymap.set("n", "<C-l>", function() tmux_navigate("l") end, { desc = "Move to right split" })
	vim.keymap.set("t", "<C-h>", function() terminal_tmux_navigate("h") end, { desc = "Move left" })
	vim.keymap.set("t", "<C-j>", function() terminal_tmux_navigate("j") end, { desc = "Move down" })
	vim.keymap.set("t", "<C-k>", function() terminal_tmux_navigate("k") end, { desc = "Move up" })
	vim.keymap.set("t", "<C-l>", function() terminal_tmux_navigate("l") end, { desc = "Move right" })
end

return M
