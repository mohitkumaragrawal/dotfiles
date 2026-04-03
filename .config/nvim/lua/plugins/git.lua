local util = require("plugins.util")

local gitsigns_configured = false

local gitsigns_opts = {
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

local M = {
	specs = {
		{ src = "https://github.com/tpope/vim-fugitive", name = "vim-fugitive" },
		{ src = "https://github.com/tpope/vim-rhubarb", name = "vim-rhubarb" },
		{ src = "https://github.com/lewis6991/gitsigns.nvim", name = "gitsigns.nvim" },
	},
}

function M.load_fugitive()
	util.load({ "vim-fugitive", "vim-rhubarb" })
end

function M.load_gitsigns()
	if gitsigns_configured then
		return
	end

	util.load("gitsigns.nvim")
	require("gitsigns").setup(gitsigns_opts)
	gitsigns_configured = true
end

function M.register()
	util.on_cmdundefined({ "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Ggrep", "GBrowse" }, M.load_fugitive)
end

return M
