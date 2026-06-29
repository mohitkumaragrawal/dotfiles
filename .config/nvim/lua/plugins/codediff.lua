local packadd = require("plugins.util").packadd

local M = {
  name = "codediff",
}

local opts = {
  explorer = {
    position = "bottom",
    hidden = true
  }
}

function M.setup()
  packadd(M.name)
  require("codediff").setup(opts)
end

return M
