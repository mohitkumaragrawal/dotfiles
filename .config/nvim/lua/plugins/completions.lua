local util = require("plugins.util")

local configured = false

local opts = {
	enabled = function()
		if vim.fn.getcmdtype() ~= "" then
			return true
		end

		return not vim.tbl_contains({ "oil", "txt", "markdown", "md" }, vim.bo.filetype)
	end,
	keymap = { preset = "enter" },
	appearance = {
		nerd_font_variant = "mono",
	},
	completion = { documentation = { auto_show = false } },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
}

local M = {
	specs = {
		{ src = "https://github.com/rafamadriz/friendly-snippets", name = "friendly-snippets" },
		{
			src = "https://github.com/saghen/blink.cmp",
			name = "blink.cmp",
			version = vim.version.range("1.*"),
		},
	},
}

function M.load()
	if configured then
		return
	end

	util.load({ "friendly-snippets", "blink.cmp" })
	require("blink.cmp").setup(opts)
	configured = true
end

function M.register()
	util.on_events({ "InsertEnter", "CmdlineEnter" }, M.load, { once = true })
end

return M
