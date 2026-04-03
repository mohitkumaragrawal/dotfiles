local util = require("plugins.util")

local configured = false

local opts = {
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
	ensure_installed = {
		"c", "cpp", "python", "lua", "vimdoc", "html", "javascript", "css",
		"scala", "typescript", "tsx", "json", "go", "yaml",
		"git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
	},
	auto_install = true,
}

local M = {
	specs = {
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", name = "nvim-treesitter" },
	},
	builds = {
		["nvim-treesitter"] = function()
			require("plugins.treesitter").load()
			vim.cmd("TSUpdate")
		end,
	},
}

function M.load()
	if configured then
		return
	end

	util.load("nvim-treesitter")
	require("nvim-treesitter.configs").setup(opts)
	configured = true
end

return M
