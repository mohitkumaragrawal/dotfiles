local util = require("plugins.util")

local render_configured = false

local M = {
	specs = {
		{ src = "https://github.com/iamcco/markdown-preview.nvim", name = "markdown-preview.nvim" },
		{ src = "https://github.com/nvim-mini/mini.nvim", name = "mini.nvim" },
		{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", name = "render-markdown.nvim" },
	},
	builds = {
		["markdown-preview.nvim"] = function(path)
			util.shell_build("markdown-preview.nvim", "cd app && npm install", path)
		end,
	},
}

function M.init()
	vim.g.mkdp_filetypes = { "markdown" }
end

function M.load_preview()
	util.load("markdown-preview.nvim")
end

function M.load_render()
	if render_configured then
		return
	end

	util.load({ "mini.nvim", "render-markdown.nvim" })
	require("render-markdown").setup({})
	render_configured = true
end

function M.register()
	util.on_cmdundefined({ "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" }, M.load_preview)
	util.on_filetypes({ "markdown", "mdx" }, M.load_render)
end

return M
