local packadd = require("plugins.util").packadd

local M = {
	name = "nvim-treesitter",
}

local parsers = {
	"bash",
	"c",
	"cpp",
	"css",
	"diff",
	"git_config",
	"gitattributes",
	"gitcommit",
	"gitignore",
	"go",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"markdown_inline",
	"python",
	"query",
	"scala",
	"tmux",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

local filetypes = {
	"bash",
	"c",
	"cpp",
	"css",
	"diff",
	"gitconfig",
	"gitattributes",
	"gitcommit",
	"gitignore",
	"go",
	"html",
	"javascript",
	"json",
	"lua",
	"markdown",
	"python",
	"query",
	"scala",
	"tmux",
	"typescript",
	"typescriptreact",
	"vim",
	"vimdoc",
	"yaml",
}

function M.setup()
	packadd(M.name)

	require("nvim-treesitter").setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
		pattern = filetypes,
		callback = function()
			pcall(vim.treesitter.start)
		end,
	})
end

function M.build()
	packadd(M.name)
	return require("nvim-treesitter").install(parsers, { force = true })
end

return M
