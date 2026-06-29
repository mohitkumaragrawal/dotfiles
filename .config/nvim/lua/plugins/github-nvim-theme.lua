local packadd = require("plugins.util").packadd

local M = {
  name = "github-nvim-theme",
}

function M.setup()
  packadd(M.name)

  local C = require("github-theme.lib.color")
  local pal = require("github-theme.palette").load("github_dark_high_contrast")
  local spec = pal.generate_spec(pal)

  local bg = C(spec.bg0)
  local dim = bg:blend(C(spec.fg1), 0.11):to_css()
  local dim_scope = bg:blend(C(spec.fg1), 0.16):to_css()
  local dim_sep = bg:blend(C(spec.fg1), 0.10):to_css()

  require("github-theme").setup({
    groups = {
      all = {
        IblIndent = { fg = dim },
        IblWhitespace = { fg = dim },
        IblScope = { fg = dim_scope },
        IndentBlankLineChar = { fg = dim },
        IndentBlankLineContextChar = { fg = dim },
        VertSplit = { fg = dim_sep },
        WinSeparator = { fg = dim_sep },
        ColorColumn = { bg = bg:blend(C(spec.fg1), 0.05):to_css() },
      }
    }
  })
end

return M
