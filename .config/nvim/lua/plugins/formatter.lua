return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
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
			format_on_save = function(bufnr)
				if vim.g.format_on_save == false then
					return
				end
				return {
					timeout_ms = 500,
					lsp_fallback = true,
				}
			end,
		},
		init = function()
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
		end,
	},
}
