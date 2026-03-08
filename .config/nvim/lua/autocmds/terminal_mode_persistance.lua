-- Create a group for our terminal logic
local term_group = vim.api.nvim_create_augroup("TerminalModePersistence", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
	group = term_group,
	pattern = "term://*",
	callback = function()
		if vim.b.last_terminal_mode == "t" then
			vim.cmd("startinsert")
			vim.b.last_terminal_mode = nil
		end
	end,
})
