local packadd = require("plugins.util").packadd

local M = {
	name = "render-markdown.nvim",
}

function M.setup()
	packadd({ "mini.nvim", M.name })
	require("render-markdown").setup({
    code = {
      disable_background = true,
      inline = false
    },
    heading = {
      backgrounds = {}
    },
    anti_conceal = {
      enabled = false
    }
  })
end

return M
