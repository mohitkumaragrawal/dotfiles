return {
	{ "tpope/vim-fugitive" },
	{ "tpope/vim-rhubarb" },
	{
		"lewis6991/gitsigns.nvim",
		lazy = false,
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "" },
				untracked = { text = "▎" },
			},
			signcolumn = true, -- Always show the signcolumn
			linehl = false, -- Don't highlight the entire line
			word_diff = false, -- Don't do word-level diffs

			current_line_blame = true,

			on_attach = function(bufnr)
				local gs = require("gitsigns")

				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, {
						buffer = bufnr,
						desc = desc,
					})
				end

				-- Navigation
				map("n", "gn", function()
					gs.nav_hunk("next")
				end, "Next hunk")
				map("n", "gp", function()
					gs.nav_hunk("prev")
				end, "Prev hunk")

				-- Actions on hunks
				map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
				-- map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
				map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")

				-- Blame & Diff
				map("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, "Show blame")
				map("n", "<leader>gd", gs.diffthis, "Show diff")
				map("n", "<leader>gD", function()
					gs.diffthis("~")
				end, "Show diff against base")
				map("n", "<leader>gh", gs.preview_hunk, "Preview hunk") -- New keymap for previewing hunks

				-- Toggling
				map("n", "<leader>gt", gs.toggle_signs, "Toggle gitsigns")
				map("n", "<leader>gv", gs.toggle_current_line_blame, "Toggle blame")
			end,
		},
	},
}
