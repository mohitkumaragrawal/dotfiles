local packadd = require("plugins.util").packadd

local M = {
	name = "telescope-fzf-native.nvim",
}

function M.build(path)
	local result = vim.system({ "make" }, { cwd = path, text = true }):wait()
	if result.code ~= 0 then
		error(result.stderr ~= "" and result.stderr or "Failed to build telescope-fzf-native.nvim")
	end
end

function M.setup()
	packadd(M.name)
	require("telescope").load_extension("fzf")
end

return M
