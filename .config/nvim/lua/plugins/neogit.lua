local packadd = require("plugins.util").packadd

local M = {
	name = "neogit",
}

local opts = {
	integrations = {
		diffview = true,
	},
	diff_viewer = "diffview",
	graph_style = "kitty",
	commit_view = {
		kind = "tab",
	},
}

local keys = {
	{ "<leader>gg", function() require("neogit").open() end, desc = "Open Neogit" },
	{ "<leader>gc", function() require("neogit").open({ "commit" }) end, desc = "Commit Popup" },
	{ "<leader>gp", function() require("neogit").open({ "push" }) end, desc = "Push Popup" },
	{ "<leader>gl", function() require("neogit").open({ "pull" }) end, desc = "Pull Popup" },
	{
		"<leader>go",
		function()
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname == "" then
				vim.cmd("DiffviewOpen")
				return
			end

			vim.cmd("DiffviewFileHistory %")
		end,
		desc = "Open Diffview",
	},
	{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
}

function M.setup()
	packadd({ "plenary.nvim", "diffview.nvim", M.name })
	require("neogit").setup(opts)

	for _, key in ipairs(keys) do
		vim.keymap.set(key.mode or "n", key[1], key[2], {
			desc = key.desc,
		})
	end
end

return M
