local util = require("plugins.util")

local configured = false

local M = {
	specs = {
		{ src = "https://github.com/j-hui/fidget.nvim", name = "fidget.nvim" },
	},
}

function M.load()
	if configured then
		return
	end

	util.load("fidget.nvim")
	require("fidget").setup({})
	configured = true
end

function M.register()
	util.on_events("LspAttach", M.load, { once = true })
end

return M
