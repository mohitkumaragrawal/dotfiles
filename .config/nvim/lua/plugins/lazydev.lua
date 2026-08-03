local packadd = require("plugins.util").packadd

local M = {
	name = "lazydev.nvim",
}

local opts = {
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
}

function M.setup()
	packadd(M.name)
	require("lazydev").setup(opts)
end

return M
