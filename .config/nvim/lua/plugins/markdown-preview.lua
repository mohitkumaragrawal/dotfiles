local packadd = require("plugins.util").packadd

local M = {
	name = "markdown-preview.nvim",
}

function M.setup()
	vim.g.mkdp_filetypes = { "markdown" }
  vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/static/custom_markdown.css")
	packadd(M.name)
end

function M.build(path)
	local result = vim.system({ vim.o.shell, vim.o.shellcmdflag, "cd app && npm install" }, {
		cwd = path,
		text = true,
	}):wait()

	if result.code ~= 0 then
		vim.notify(
			("Build failed for %s\n%s"):format(M.name, result.stderr or result.stdout or ""),
			vim.log.levels.ERROR
		)
	end
end

return M
