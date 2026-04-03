vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_remote_plugins = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_nvim_net_plugin = 1
vim.g.editorconfig = false
vim.g.loaded_spellfile_plugin = true

require("options")
require("keymaps")

require("integrations.neovide")

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("agent_context").setup()
	end,
})

vim.diagnostic.config({
	virtual_text = true,
})
require("plugins").setup()

vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
})
-- status
