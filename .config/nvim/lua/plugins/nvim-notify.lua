local packadd = require("plugins.util").packadd

local M = {
	name = "nvim-notify",
}

local opts = {
	render = "wrapped-compact",
	fps = 60,
	timeout = 1000,
	stages = "fade",
	top_down = false,
}

function M.setup()
	packadd(M.name)
	require("notify").setup(opts)
end

return M
