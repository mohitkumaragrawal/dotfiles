local packadd = require("plugins.util").packadd

local M = {
	name = "mini.nvim",
}

function M.setup()
	packadd({ M.name })
	require("mini.pick").setup()
  require("mini.move").setup()
  require("mini.files").setup()
  require("mini.jump").setup()

  local clue = require("mini.clue")
	clue.setup({
		triggers = {
			{ mode = { "n", "x" }, keys = "<leader>" },
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
    window = {
      delay = 0
    }
	})
end

return M
