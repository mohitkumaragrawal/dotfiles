local packadd = require("plugins.util").packadd

local M = {
	name = "mini.nvim",
}

function M.setup()
	packadd({ M.name })
	require("mini.pick").setup()

	local clue = require("mini.clue")
	clue.setup({
		triggers = {
			{ mode = "n", keys = "<leader>" },
			{ mode = "x", keys = "<leader>" },
			{ mode = "n", keys = "<C-Space>" },
			{ mode = "i", keys = "<C-x>" },
		},
		clues = {
			clue.gen_clues.g(),
			clue.gen_clues.marks(),
			clue.gen_clues.registers(),
			clue.gen_clues.windows(),
			clue.gen_clues.z(),
		},
	})
end

return M
