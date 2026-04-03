local util = require("plugins.util")

local modules = {
	require("plugins.ai"),
	require("plugins.completions"),
	require("plugins.fidget"),
	require("plugins.formatter"),
	require("plugins.git"),
	require("plugins.indent-blankline"),
	require("plugins.lsp"),
	require("plugins.lualine"),
	require("plugins.markdown"),
	require("plugins.noice"),
	require("plugins.notify"),
	require("plugins.oil"),
	require("plugins.snacks"),
	require("plugins.theme"),
	require("plugins.treesitter"),
	require("plugins.vim-commentary"),
	require("plugins.vim-surround"),
	require("plugins.vim-tmux-navigator"),
}

local M = {}

local function collect_specs()
	local specs = {
		{ src = "https://github.com/nvim-tree/nvim-web-devicons", name = "nvim-web-devicons" },
	}

	for _, module in ipairs(modules) do
		for _, spec in ipairs(module.specs or {}) do
			table.insert(specs, spec)
		end
	end

	return specs
end

local function collect_builds()
	local builds = {}
	for _, module in ipairs(modules) do
		for name, build in pairs(module.builds or {}) do
			builds[name] = build
		end
	end
	return builds
end

function M.setup()
	for _, module in ipairs(modules) do
		if type(module.init) == "function" then
			module.init()
		end
	end

	util.register_build_hooks(collect_builds())
	util.install(collect_specs())
	util.load("nvim-web-devicons")

	require("plugins.theme").load()
	require("plugins.vim-tmux-navigator").load()
	require("plugins.snacks").load()
	require("plugins.oil").load()
	require("plugins.treesitter").load()
	require("plugins.indent-blankline").load()
	require("plugins.formatter").load()
	require("plugins.git").load_gitsigns()
	require("plugins.vim-commentary").load()
	require("plugins.vim-surround").load()
	require("plugins.lualine").load()

	for _, module in ipairs(modules) do
		if type(module.register) == "function" then
			module.register()
		end
	end
end

return M
