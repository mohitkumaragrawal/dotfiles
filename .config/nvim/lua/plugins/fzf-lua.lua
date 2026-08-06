local packadd = require("plugins.util").packadd

local M = {
	name = "fzf-lua",
}

local function map(keys, picker, desc)
	vim.keymap.set("n", keys, picker, { desc = desc })
end

function M.setup()
	packadd(M.name)
	local fzf = require("fzf-lua")
	fzf.setup({
		fzf_colors = true,
		winopts = {
			backdrop = 100,
		},
		keymap = {
			builtin = {
				["<C-d>"] = "preview-page-down",
				["<C-u>"] = "preview-page-up",
			},
		},
	})

	map("<leader>tf", fzf.files, "Find Files")
	map("<leader>tg", fzf.git_files, "Git Files")
	map("<leader>tr", fzf.oldfiles, "Recent")
	map("<leader>tb", fzf.buffers, "Buffers")
	map("<leader>ts", fzf.live_grep_native, "Live Grep")
	map("<leader>th", fzf.helptags, "Help Tags")

	map("<leader><space>", fzf.vcs_files, "Smart Find Files")
	map("<leader>,", fzf.buffers, "Buffers")
	map("<leader>/", fzf.live_grep_native, "Grep")
	map("<leader>:", fzf.command_history, "Command History")

	map("<leader>fc", function()
		fzf.files({ cwd = vim.fn.stdpath("config") })
	end, "Find Config File")

	map("<leader>ff", fzf.files, "Find Files")
	map("<leader>fg", fzf.git_files, "Find Git Files")
	map("<leader>fa", fzf.builtin, "Choose Picker")
	map("<leader>fs", function()
		require("search_profiles").open_picker()
	end, "Search Profiles")
	map("<leader>fr", fzf.oldfiles, "Recent")
	map("<leader>sb", fzf.blines, "Buffer Lines")
	map('<leader>s"', fzf.registers, "Registers")
	map("<leader>s/", fzf.search_history, "Search History")
	map("<leader>sa", fzf.autocmds, "Autocmds")
	map("<leader>sC", fzf.commands, "Commands")
	map("<leader>sd", fzf.diagnostics_workspace, "Diagnostics")
	map("<leader>sD", fzf.diagnostics_document, "Buffer Diagnostics")
	map("<leader>sh", fzf.helptags, "Help Pages")
	map("<leader>sH", fzf.highlights, "Highlights")
	map("<leader>sj", fzf.jumps, "Jumplist")
	map("<leader>sk", fzf.keymaps, "Keymaps")
	map("<leader>sl", fzf.loclist, "Location List")
	map("<leader>sm", fzf.marks, "Marks")
	map("<leader>sM", fzf.manpages, "Man Pages")
	map("<leader>sp", function()
		fzf.files({ cwd = vim.fn.stdpath("config") .. "/lua/plugins" })
	end, "Plugin Config")
	map("<leader>sq", fzf.quickfix, "Quickfix List")
	map("<leader>sR", fzf.resume, "Resume")
	map("<leader>uC", fzf.colorschemes, "Colorschemes")

	map("gd", fzf.lsp_definitions, "Goto Definition")
	map("gr", fzf.lsp_references, "References")
	map("gI", fzf.lsp_implementations, "Goto Implementation")
	map("gy", fzf.lsp_typedefs, "Goto T[y]pe Definition")
	map("gai", fzf.lsp_incoming_calls, "C[a]lls Incoming")
	map("gao", fzf.lsp_outgoing_calls, "C[a]lls Outgoing")
	map("<leader>ss", fzf.lsp_document_symbols, "LSP Symbols")
	map("<leader>sS", fzf.lsp_workspace_symbols, "LSP Workspace Symbols")
end

return M
