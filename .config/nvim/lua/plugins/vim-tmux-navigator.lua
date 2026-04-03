local util = require("plugins.util")

local M = {
	specs = {
		{ src = "https://github.com/christoomey/vim-tmux-navigator", name = "vim-tmux-navigator" },
	},
}

function M.init()
	vim.g.tmux_navigator_no_mappings = 1
end

function M.load()
	util.load("vim-tmux-navigator")
end

return M
