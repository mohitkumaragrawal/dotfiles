local packadd = require("plugins.util").packadd

local M = {
	name = "nvim-web-devicons",
}

function M.setup()
	packadd(M.name)
end

return M
