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
