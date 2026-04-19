local packadd = require("plugins.util").packadd

local M = {
	name = "blink.cmp",
}

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

function M.setup()
	packadd({ "friendly-snippets", M.name })
	require("blink.cmp").setup(opts)
end

return M
