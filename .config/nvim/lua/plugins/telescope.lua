local packadd = require("plugins.util").packadd

local M = {
	name = "telescope.nvim",
}

local function t(keys, fn, desc)
	vim.keymap.set("n", keys, fn, { desc = desc })
end

function M.setup()
	packadd(M.name)
	local actions = require("telescope.actions")
	require("telescope").setup({
		defaults = {
			mappings = {
				n = {
					["<esc>"] = {
						actions.close,
						type = "action",
						opts = { nowait = true },
					},
				},
			},
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	})

	local b = require("telescope.builtin")

	t("<leader>tf", b.find_files, "Find Files")
	t("<leader>tg", b.git_files, "Git Files")
	t("<leader>tr", b.oldfiles, "Recent")
	t("<leader>tb", b.buffers, "Buffers")
	t("<leader>ts", b.live_grep, "Live Grep")
	t("<leader>th", b.help_tags, "Help Tags")

	t("<leader><space>", b.find_files, "Smart Find Files")
	t("<leader>,", b.buffers, "Buffers")
	t("<leader>/", b.live_grep, "Grep")
	t("<leader>:", b.command_history, "Command History")

	t("<leader>fc", function()
		b.find_files({ cwd = vim.fn.stdpath("config") })
	end, "Find Config File")

	t("<leader>ff", b.find_files, "Find Files")
	t("<leader>fg", b.git_files, "Find Git Files")
	t("<leader>fa", b.builtin, "Choose Picker")
	t("<leader>fs", function()
		require("search_profiles").open_picker()
	end, "Search Profiles")
	t("<leader>fr", b.oldfiles, "Recent")
	t("<leader>sb", b.current_buffer_fuzzy_find, "Buffer Lines")
	t('<leader>s"', b.registers, "Registers")
	t("<leader>s/", b.search_history, "Search History")
	t("<leader>sa", b.autocommands, "Autocmds")
	t("<leader>sC", b.commands, "Commands")
	t("<leader>sd", b.diagnostics, "Diagnostics")

	t("<leader>sD", function()
		b.diagnostics({ bufnr = 0 })
	end, "Buffer Diagnostics")

	t("<leader>sh", b.help_tags, "Help Pages")
	t("<leader>sH", b.highlights, "Highlights")
	t("<leader>sj", b.jumplist, "Jumplist")
	t("<leader>sk", b.keymaps, "Keymaps")
	t("<leader>sl", b.loclist, "Location List")
	t("<leader>sm", b.marks, "Marks")
	t("<leader>sM", b.man_pages, "Man Pages")

	t("<leader>sp", function()
		b.find_files({ cwd = vim.fn.stdpath("config") .. "/lua/plugins" })
	end, "Plugin Config")

	t("<leader>sq", b.quickfix, "Quickfix List")
	t("<leader>sR", b.resume, "Resume")
	t("<leader>uC", b.colorscheme, "Colorschemes")

	t("gd", b.lsp_definitions, "Goto Definition")
	t("gr", b.lsp_references, "References")
	t("gI", b.lsp_implementations, "Goto Implementation")
	t("gy", b.lsp_type_definitions, "Goto T[y]pe Definition")
	t("gai", b.lsp_incoming_calls, "C[a]lls Incoming")
	t("gao", b.lsp_outgoing_calls, "C[a]lls Outgoing")
	t("<leader>ss", b.lsp_document_symbols, "LSP Symbols")
	t("<leader>sS", b.lsp_workspace_symbols, "LSP Workspace Symbols")
end

return M
