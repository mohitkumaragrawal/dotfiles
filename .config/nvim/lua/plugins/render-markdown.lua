local packadd = require("plugins.util").packadd

local M = {
	name = "render-markdown.nvim",
}

function M.setup()
	packadd({ "mini.nvim", M.name })
	require("render-markdown").setup({})
end

return M
