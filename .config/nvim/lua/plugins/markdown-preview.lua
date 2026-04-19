local packadd = require("plugins.util").packadd

local M = {
	name = "markdown-preview.nvim",
}

function M.setup()
	vim.g.mkdp_filetypes = { "markdown" }
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
