return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
    ensure_installed = {
      "c", "cpp", "python", "lua", "vimdoc", "html", "javascript", "css",
      "scala", "typescript", "tsx", "json", "go", "yaml",
      "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore"
    },
    auto_install = true,
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end
}

