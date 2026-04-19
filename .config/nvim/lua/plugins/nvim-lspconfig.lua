local packadd = require("plugins.util").packadd

local M = {
	name = "nvim-lspconfig",
}

function M.setup()
	packadd(M.name)

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client then
				client.server_capabilities.semanticTokensProvider = nil
			end
		end,
	})

	local ok, scala = pcall(require, "local.scala")
	if ok then
		scala.setup()
	end
end

return M
