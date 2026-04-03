local util = require("plugins.util")

local configured = false

local opts = {
	render = "wrapped-compact",
	fps = 60,
	timeout = 1000,
	stages = "fade",
	top_down = false,
}

local M = {
	specs = {
		{ src = "https://github.com/rcarriga/nvim-notify", name = "nvim-notify" },
	},
}

function M.load()
	if configured then
		return
	end

	util.load("nvim-notify")
	require("notify").setup(opts)
	configured = true
end

return M
