return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    highlight = {
      enable = true,
      disable = function(lang, bufnr)
        return vim.api.nvim_buf_line_count(bufnr) > 5000
      end,
      additional_vim_regex_highlighting = { "latex" },
    },
  },
}
