local packadd = require("plugins.util").packadd

local M = {
	name = "noice.nvim",
}

local opts = {
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
		signature = {
			enabled = false,
		},
		hover = {
			silent = true,
			opts = {
				win_options = {
					winhighlight = {
						Normal = "LspHoverNormal",
						FloatBorder = "LspHoverBorder",
					},
				},
			},
		},
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		inc_rename = false,
	},
}

function M.setup()
	packadd({ "nui.nvim", M.name })
	require("noice").setup(opts)
end

return M
