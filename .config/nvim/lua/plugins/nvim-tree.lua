local function natural_cmp(left, right)
	local a_is_dir = (left.type == "directory")
	local b_is_dir = (right.type == "directory")

	if a_is_dir and not b_is_dir then
		return true -- 'a' is a directory and comes first
	end
	if not a_is_dir and b_is_dir then
		return false -- 'b' is a directory and comes first
	end

	left = left.name:lower()
	right = right.name:lower()

	if left == right then
		return false
	end

	for i = 1, math.max(string.len(left), string.len(right)), 1 do
		local l = string.sub(left, i, -1)
		local r = string.sub(right, i, -1)

		if type(tonumber(string.sub(l, 1, 1))) == "number" and type(tonumber(string.sub(r, 1, 1))) == "number" then
			local l_number = tonumber(string.match(l, "^[0-9]+"))
			local r_number = tonumber(string.match(r, "^[0-9]+"))

			if l_number ~= r_number then
				return l_number < r_number
			end
		elseif string.sub(l, 1, 1) ~= string.sub(r, 1, 1) then
			return l < r
		end
	end
end

return {
	"nvim-tree/nvim-tree.lua",
	enabled = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"ibhagwan/fzf-lua",
	}, -- Dependency for icons
	name = "nvim-tree",
	event = "VimEnter",
	opts = {
		disable_netrw = true,
		hijack_netrw = true,
		hijack_cursor = true,
		view = {
			width = {
				min = 30,
				max = 50,
			},
		},
		git = {
			enable = false,
		},
		diagnostics = {
			enable = false,
		},
		sort_by = function(nodes)
			table.sort(nodes, natural_cmp)
		end,
		filters = {
			git_ignored = true,
			dotfiles = false,
		},
		renderer = {
			symlink_destination = false,
		},
		on_attach = function(bufnr)
			local opts = { buffer = bufnr }
			local api = require("nvim-tree.api")
			local M = vim.keymap.set
			api.config.mappings.default_on_attach(bufnr)
			vim.keymap.del("n", "<C-K>", opts)
			-- function for left to assign to keybindings
			local lefty = function()
				local node_at_cursor = api.tree.get_node_under_cursor()
				-- if it's a node and it's open, close
				if node_at_cursor.nodes and node_at_cursor.open then
					api.node.open.edit()
				-- else left jumps up to parent
				else
					api.node.navigate.parent()
				end
			end
			-- function for right to assign to keybindings
			local righty = function()
				local node_at_cursor = api.tree.get_node_under_cursor()
				-- if it's a closed node, open it
				if node_at_cursor.nodes and not node_at_cursor.open then
					api.node.open.edit()
				end
			end

			local live_grep_dir = function()
				local node = api.tree.get_node_under_cursor()
				local fzf_lua = require("fzf-lua")

				-- Check if the selected node is a directory
				if node.type == "directory" then
					fzf_lua.live_grep({
						-- Set the current working directory to the path of the selected directory
						cwd = node.absolute_path,
					})
				else
					-- If it's a file, launch live grep in the file's directory
					fzf_lua.live_grep({
						cwd = vim.fn.fnamemodify(node.absolute_path, ":h"),
					})
				end
			end

			M("n", "h", lefty, opts)
			M("n", "<Left>", lefty, opts)
			M("n", "<Right>", righty, opts)
			M("n", "l", righty, opts)

			-- live grep for a directory
			M("n", "<leader>/", live_grep_dir, opts)
			M("n", "<leader>fr", live_grep_dir, opts)
			M("n", "K", api.node.show_info_popup, opts)
		end,
	},
	keys = {
		{
			"<leader>e",
			function()
				require("nvim-tree.api").tree.toggle({ focus = true, find_file = true })
			end,
			desc = "Toggle NvimTree and reveal current file",
		},
	},
	config = function(_, opts)
		require("nvim-tree").setup(opts)
		local group = vim.api.nvim_create_augroup("NvimTreeAutoReveal", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "VimEnter" }, {
			group = group,
			callback = function()
				if require("nvim-tree.api").tree.is_visible() then
					require("nvim-tree.api").tree.find_file()
				end
			end,
			pattern = "*",
		})

		local augroup = vim.api.nvim_create_augroup("NvimTreeCwd", { clear = true })
		vim.api.nvim_create_autocmd("VimEnter", {
			group = augroup,
			desc = "Set CWD to directory passed as argument",
			callback = function()
				if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
					vim.cmd.cd(vim.fn.fnameescape(vim.fn.argv(0)))
					vim.cmd.NvimTreeToggle()
				end
			end,
			once = true, -- Run this only once on startup
		})
	end,
}
