local util = require("plugins.util")

local configured = false

local opts = {
	indent = {
		char = "▏",
	},
}

local M = {
	specs = {
		{ src = "https://github.com/lukas-reineke/indent-blankline.nvim", name = "indent-blankline.nvim" },
	},
}

function M.load()
	if configured then
		return
	end

	util.load("indent-blankline.nvim")
	require("ibl").setup(opts)
	configured = true
end

return M
