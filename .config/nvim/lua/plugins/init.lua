local specs = require("plugins.specs")

local plugins = {
	require("plugins.nvim-web-devicons"),
	require("plugins.kanagawa"),
	require("plugins.nvim-notify"),
	require("plugins.noice"),
	require("plugins.snacks"),
	require("plugins.lualine"),
	require("plugins.indent-blankline"),
	require("plugins.blink-cmp"),
	require("plugins.conform"),
	require("plugins.copilot-vim"),
	require("plugins.vim-commentary"),
	require("plugins.vim-surround"),
	require("plugins.vim-fugitive"),
	require("plugins.gitsigns"),
	require("plugins.mason"),
	require("plugins.mason-lspconfig"),
	require("plugins.nvim-lspconfig"),
	require("plugins.lazydev"),
	require("plugins.fidget"),
	require("plugins.trouble"),
	require("plugins.vim-tmux-navigator"),
	require("plugins.oil"),
	require("plugins.markdown-preview"),
	require("plugins.render-markdown"),
}

local M = {}

local build_hooks = {}

for _, plugin in ipairs(plugins) do
	if plugin.build then
		build_hooks[plugin.name] = plugin.build
	end
end

local function register_build_hooks()
	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PluginsBuildHooks", { clear = true }),
		callback = function(ev)
			local build = build_hooks[ev.data.spec.name]
			if not build then
				return
			end

			if ev.data.kind == "install" or ev.data.kind == "update" then
				build(ev.data.path)
			end
		end,
	})
end

function M.setup()
	register_build_hooks()

	vim.pack.add(specs, {
		load = false,
		confirm = false,
	})

	for _, plugin in ipairs(plugins) do
		plugin.setup()
	end
end

return M
