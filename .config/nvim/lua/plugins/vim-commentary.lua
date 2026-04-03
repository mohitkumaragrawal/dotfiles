local util = require("plugins.util")

local M = {
	specs = {
		{ src = "https://github.com/tpope/vim-commentary", name = "vim-commentary" },
	},
}

function M.load()
	util.load("vim-commentary")
end

return M
