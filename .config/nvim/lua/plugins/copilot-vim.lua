local packadd = require("plugins.util").packadd

local M = {
	name = "copilot.vim",
}

function M.setup()
	packadd(M.name)
end

return M
