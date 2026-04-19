local packadd = require("plugins.util").packadd

local M = {
	name = "vim-fugitive",
}

function M.setup()
	packadd({ M.name, "vim-rhubarb" })
end

return M
