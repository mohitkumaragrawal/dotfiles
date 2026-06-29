local packadd = require("plugins.util").packadd

local M = {
  name = "vscode"
}

function M.setup()
  packadd(M.name)
  require("vscode").setup({})

  vim.cmd.colorscheme("vscode")
end

return M
