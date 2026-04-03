local util = require("plugins.util")
local notify = require("plugins.notify")

local configured = false

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

local M = {
	specs = {
		{ src = "https://github.com/MunifTanjim/nui.nvim", name = "nui.nvim" },
		{ src = "https://github.com/folke/noice.nvim", name = "noice.nvim" },
	},
}

function M.load()
	if configured then
		return
	end

	notify.load()
	util.load({ "nui.nvim", "noice.nvim" })
	require("noice").setup(opts)
	configured = true
end

function M.register()
	util.on_vimenter(M.load)
end

return M
