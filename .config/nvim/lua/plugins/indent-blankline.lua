local packadd = require("plugins.util").packadd

local M = {
	name = "indent-blankline.nvim",
}

function M.setup()
	packadd(M.name)
	require("ibl").setup({
		indent = {
			char = "▏",
		},
	})
end

return M
