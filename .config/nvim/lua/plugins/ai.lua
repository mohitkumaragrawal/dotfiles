local util = require("plugins.util")

local M = {
	specs = {
		{ src = "https://github.com/github/copilot.vim", name = "copilot.vim" },
	},
}

function M.load()
	util.load("copilot.vim")
end

function M.register()
	util.on_events("InsertEnter", M.load, { once = true })
end

return M
