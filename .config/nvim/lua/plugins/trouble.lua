local packadd = require("plugins.util").packadd

local M = {
	name = "trouble.nvim",
}

function M.setup()
	packadd(M.name)
	require("trouble").setup({})

	vim.keymap.set("n", "<leader>xX", function()
		require("trouble").toggle("diagnostics")
	end, { desc = "Diagnostics (Trouble)" })
	vim.keymap.set("n", "<leader>xx", function()
		require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } })
	end, { desc = "Buffer Diagnostics (Trouble)" })
	vim.keymap.set("n", "<leader>cs", function()
		require("trouble").toggle({ mode = "symbols", focus = false })
	end, { desc = "Symbols (Trouble)" })
	vim.keymap.set("n", "<leader>xL", function()
		require("trouble").toggle("loclist")
	end, { desc = "Location List (Trouble)" })
	vim.keymap.set("n", "<leader>xQ", function()
		require("trouble").toggle("qflist")
	end, { desc = "Quickfix List (Trouble)" })
end

return M
