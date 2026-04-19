local packadd = require("plugins.util").packadd

local M = {
	name = "gitsigns.nvim",
}

local opts = {
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "" },
		untracked = { text = "▎" },
	},
	signcolumn = true,
	linehl = false,
	word_diff = false,
	current_line_blame = true,
	on_attach = function(bufnr)
		local gs = require("gitsigns")

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, {
				buffer = bufnr,
				desc = desc,
			})
		end

		map("n", "gn", function()
			gs.nav_hunk("next")
		end, "Next hunk")
		map("n", "gp", function()
			gs.nav_hunk("prev")
		end, "Prev hunk")
		map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
		map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
		map("n", "<leader>gb", function()
			gs.blame_line({ full = true })
		end, "Show blame")
		map("n", "<leader>gd", gs.diffthis, "Show diff")
		map("n", "<leader>gD", function()
			gs.diffthis("~")
		end, "Show diff against base")
		map("n", "<leader>gh", gs.preview_hunk, "Preview hunk")
		map("n", "<leader>gt", gs.toggle_signs, "Toggle gitsigns")
		map("n", "<leader>gv", gs.toggle_current_line_blame, "Toggle blame")
	end,
}

function M.setup()
	packadd(M.name)
	require("gitsigns").setup(opts)
end

return M
