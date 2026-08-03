local packadd = require("plugins.util").packadd

local M = {
	name = "telescope.nvim",
}

function M.setup()
	packadd(M.name)
	local actions = require("telescope.actions")
	require("telescope").setup({
		defaults = {
			mappings = {
				n = {
					["<esc>"] = {
						actions.close,
						type = "action",
						opts = { nowait = true },
					},
				},
			},
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	})
end

return M
