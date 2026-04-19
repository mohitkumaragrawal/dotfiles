local packadd = require("plugins.util").packadd

local M = {
	name = "mason-lspconfig.nvim",
}

function M.setup()
	packadd(M.name)
	require("mason-lspconfig").setup({ auto_install = false })
end

return M
