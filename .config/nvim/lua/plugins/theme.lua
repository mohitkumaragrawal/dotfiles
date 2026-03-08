return {
	{
		"rebelot/kanagawa.nvim",
		opts = {
			colors = {
				theme = {
					all = {
						ui = {
							bg_gutter = "none",
						},
					},
				},
			},
			commentStyle = { italic = false },
			keywordStyle = { italic = false },
			overrides = function(colors)
				local theme = colors.theme
				local makeDiagnosticColor = function(color)
					local c = require("kanagawa.lib.color")
					return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
				end
				return {
					NormalFloat = { bg = "none" },
					FloatTitle = { bg = "none" },
					FloatBorder = { bg = "NONE", fg = colors.palette.springBlue },
					DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
					DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
					DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
					DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),
					Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency,,
					PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
					PmenuSbar = { bg = theme.ui.bg_m1 },
					PmenuThumb = { bg = colors.palette.boatYellow2 },
					BlinkCmpMenuBorder = { fg = "NONE", bg = "NONE" },
					CursorLineNr = { fg = colors.palette.sakuraPink, bg = "NONE" },
					CursorLine = { fg = "NONE", bg = theme.ui.bg_p1 },
					IblIndent = { fg = theme.ui.bg_p1, bg = "NONE" },
					IblWhitespace = { fg = theme.ui.bg_p1, bg = "NONE" },
					IblScope = { fg = theme.ui.bg_p2, bg = "NONE" },
				}
			end,
		},
		lazy = false,
		priority = 1000,
		config = function(_, opts)
			require("kanagawa").setup(opts)
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "kanagawa-dragon",
				callback = function()
					vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
					local colors = require("kanagawa.colors").setup({ theme = "dragon" })
					local theme = colors.theme
					local c = require("kanagawa.lib.color")
					local dark_cursor_line = c(theme.ui.bg_p1):blend("#000000", 0.7):to_hex()
					vim.api.nvim_set_hl(0, "CursorLine", { bg = dark_cursor_line })
					local dark_indent = c(theme.ui.bg_p1):blend("#000000", 0.5):to_hex()
					vim.api.nvim_set_hl(0, "IblIndent", { fg = dark_indent })
					vim.api.nvim_set_hl(0, "IblWhitespace", { fg = dark_indent })
				end,
			})
			vim.cmd.colorscheme("kanagawa-dragon")
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function(_, opts)
			require("catppuccin").setup(opts)
			-- vim.cmd.colorscheme("catppuccin")
		end,
	},
}
