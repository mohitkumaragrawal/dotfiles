return {
  "L3MON4D3/LuaSnip",
  config = function()
    -- load snippets from path/of/your/nvim/config/my-cool-snippets
    require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snippets" } })
  end,
}
