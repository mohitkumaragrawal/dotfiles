local packadd = require("plugins.util").packadd

local M = {
	name = "mason.nvim",
}

function M.setup()
	packadd(M.name)
	require("mason").setup()
end

return M
