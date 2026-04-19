local packadd = require("plugins.util").packadd

local M = {
	name = "fidget.nvim",
}

function M.setup()
	packadd(M.name)
	require("fidget").setup({})
end

return M
