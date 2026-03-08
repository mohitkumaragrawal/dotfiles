return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "1.*",
	opts = {
		enabled = function()
			-- If in the cmdline, enable completion regardless of filetype
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
		signature = { enabled = true }
	},
}
