local util = require("plugins.util")

local configured = false

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

local M = {
	specs = {
		{ src = "https://github.com/stevearc/conform.nvim", name = "conform.nvim" },
	},
}

function M.init()
	vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	vim.g.format_on_save = false
	vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
		vim.g.format_on_save = not vim.g.format_on_save
		if vim.g.format_on_save then
			vim.notify("Formatting on save enabled")
		else
			vim.notify("Formatting on save disabled")
		end
	end, {})

	vim.keymap.set({ "n", "v" }, "<leader>cf", function()
		require("plugins.formatter").load()
		require("conform").format({ async = true, lsp_fallback = true })
	end, { desc = "Format buffer" })
end

function M.load()
	if configured then
		return
	end

	util.load("conform.nvim")
	require("conform").setup(opts)
	configured = true
end

return M
