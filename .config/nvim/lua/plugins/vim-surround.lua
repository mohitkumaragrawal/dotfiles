local util = require("plugins.util")

local M = {
	specs = {
		{ src = "https://github.com/tpope/vim-surround", name = "vim-surround" },
	},
}

function M.load()
	util.load("vim-surround")
end

return M
