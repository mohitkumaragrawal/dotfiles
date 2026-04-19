local packadd = require("plugins.util").packadd

local M = {
	name = "vim-commentary",
}

function M.setup()
	packadd(M.name)
end

return M
