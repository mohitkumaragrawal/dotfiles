require("options")
require("keymaps")

require("integrations.neovide")

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("agent_context").setup()
	end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

vim.diagnostic.config({
	virtual_text = true,
})
require("lazy").setup("plugins")

vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
})
-- status
