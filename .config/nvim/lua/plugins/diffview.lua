local packadd = require("plugins.util").packadd

local M = {
	name = "diffview.nvim",
}

local opts = {
	file_panel = {
		listing_style = "tree",
		tree_options = {
			flatten_dirs = true,
			folder_statuses = "only_folded",
		},
		win_config = {
			position = "top",
			height = 12,
		},
	},
}

function M.setup()
	packadd(M.name)
	require("diffview").setup(opts)
end

return M
