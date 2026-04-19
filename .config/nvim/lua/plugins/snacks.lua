local packadd = require("plugins.util").packadd

local M = {
	name = "snacks.nvim",
}

local opts = {
	picker = {
		main = {
			file = false,
		},
	},
	dashboard = {
		enabled = false,
	},
}

local keys = {
	{ "<leader><space>", function() require("snacks").picker.smart() end, desc = "Smart Find Files" },
	{ "<leader>,", function() require("snacks").picker.buffers() end, desc = "Buffers" },
	{ "<leader>/", function() require("snacks").picker.grep() end, desc = "Grep" },
	{ "<leader>:", function() require("snacks").picker.command_history() end, desc = "Command History" },
	{ "<leader>n", function() require("snacks").picker.notifications() end, desc = "Notification History" },
	{ "<leader>fc", function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
	{ "<leader>ff", function() require("snacks").picker.files() end, desc = "Find Files" },
	{ "<leader>fg", function() require("snacks").picker.git_files() end, desc = "Find Git Files" },
	{ "<leader>fp", function() require("snacks").picker.projects() end, desc = "Projects" },
	{ "<leader>fr", function() require("snacks").picker.recent() end, desc = "Recent" },
	{ "<leader>fs", function() require("search_profiles").open_picker() end, desc = "Search Profiles" },
	{ "<leader>fa", function() require("snacks").picker() end, desc = "Choose Picker" },
	{ "<leader>sb", function() require("snacks").picker.lines() end, desc = "Buffer Lines" },
	{ "<leader>sB", function() require("snacks").picker.grep_buffers() end, desc = "Grep Open Buffers" },
	{ '<leader>s"', function() require("snacks").picker.registers() end, desc = "Registers" },
	{ "<leader>s/", function() require("snacks").picker.search_history() end, desc = "Search History" },
	{ "<leader>sa", function() require("snacks").picker.autocmds() end, desc = "Autocmds" },
	{ "<leader>sc", function() require("snacks").picker.command_history() end, desc = "Command History" },
	{ "<leader>sC", function() require("snacks").picker.commands() end, desc = "Commands" },
	{ "<leader>sd", function() require("snacks").picker.diagnostics() end, desc = "Diagnostics" },
	{ "<leader>sD", function() require("snacks").picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
	{ "<leader>sh", function() require("snacks").picker.help() end, desc = "Help Pages" },
	{ "<leader>sH", function() require("snacks").picker.highlights() end, desc = "Highlights" },
	{ "<leader>si", function() require("snacks").picker.icons() end, desc = "Icons" },
	{ "<leader>sj", function() require("snacks").picker.jumps() end, desc = "Jumps" },
	{ "<leader>sk", function() require("snacks").picker.keymaps() end, desc = "Keymaps" },
	{ "<leader>sl", function() require("snacks").picker.loclist() end, desc = "Location List" },
	{ "<leader>sm", function() require("snacks").picker.marks() end, desc = "Marks" },
	{ "<leader>sM", function() require("snacks").picker.man() end, desc = "Man Pages" },
	{ "<leader>sp", function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") .. "/lua/plugins" }) end, desc = "Plugin Config" },
	{ "<leader>sq", function() require("snacks").picker.qflist() end, desc = "Quickfix List" },
	{ "<leader>sR", function() require("snacks").picker.resume() end, desc = "Resume" },
	{ "<leader>su", function() require("snacks").picker.undo() end, desc = "Undo History" },
	{ "<leader>uC", function() require("snacks").picker.colorschemes() end, desc = "Colorschemes" },
	{ "gd", function() require("snacks").picker.lsp_definitions() end, desc = "Goto Definition" },
	{ "gD", function() require("snacks").picker.lsp_declarations() end, desc = "Goto Declaration" },
	{ "gr", function() require("snacks").picker.lsp_references() end, nowait = true, desc = "References" },
	{ "gI", function() require("snacks").picker.lsp_implementations() end, desc = "Goto Implementation" },
	{ "gy", function() require("snacks").picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
	{ "gai", function() require("snacks").picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
	{ "gao", function() require("snacks").picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
	{ "<leader>ss", function() require("snacks").picker.lsp_symbols() end, desc = "LSP Symbols" },
	{ "<leader>sS", function() require("snacks").picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
}

function M.setup()
	packadd(M.name)
	require("snacks").setup(opts)

	for _, key in ipairs(keys) do
		vim.keymap.set(key.mode or "n", key[1], key[2], {
			desc = key.desc,
			nowait = key.nowait,
		})
	end
end

return M
