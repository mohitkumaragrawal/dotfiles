local packadd = require("plugins.util").packadd

local M = {
	name = "conform.nvim",
}

local opts = {
	formatters_by_ft = {
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescriptreact = { "prettierd" },
		css = { "prettierd" },
		html = { "prettierd" },
		json = { "prettierd" },
		yaml = { "prettierd" },
		markdown = { "prettierd" },
		lua = { "stylua" },
		python = { "ruff" },
		c = { "clang-format" },
		cpp = { "clang-format" },
	},
	format_on_save = function()
		if vim.g.format_on_save == false then
			return
		end

		return {
			timeout_ms = 500,
			lsp_fallback = true,
		}
	end,
}

function M.setup()
	vim.g.format_on_save = false
	packadd(M.name)
	require("conform").setup(opts)

	vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
		vim.g.format_on_save = not vim.g.format_on_save
		if vim.g.format_on_save then
			vim.notify("Formatting on save enabled")
		else
			vim.notify("Formatting on save disabled")
		end
	end, {})

	vim.o.formatexpr = "v:lua.require'plugins.conform'.formatexpr()"
	vim.keymap.set({ "n", "v" }, "<leader>cf", function()
		require("conform").format({ async = true, lsp_fallback = true })
	end, { desc = "Format buffer" })
end

function M.formatexpr()
	return require("conform").formatexpr()
end

return M
