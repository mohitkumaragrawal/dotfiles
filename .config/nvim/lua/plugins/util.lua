local M = {}

function M.listify(value)
	if value == nil then
		return {}
	end

	if vim.islist(value) then
		return value
	end

	return { value }
end

function M.packadd(names)
	for _, name in ipairs(M.listify(names)) do
		vim.cmd.packadd(name)
	end
end

return M
