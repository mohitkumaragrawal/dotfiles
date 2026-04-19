local packadd = require("plugins.util").packadd

local M = {
	name = "oil.nvim",
}

local detail_popup_id = nil

local file_associations = {
	pdf = "zathura",
	jpg = "imv",
	png = "imv",
	jpeg = "imv",
	mp4 = "mpv",
	mp3 = "mpv",
}

local opts = {
	columns = { "icon" },
	keymaps = {
		["gx"] = {
			function()
				local oil = require("oil")
				local entry = oil.get_cursor_entry()
				local dir = oil.get_current_dir()
				if not entry or not dir then
					return
				end

				local path = dir .. entry.name
				local ext = entry.name:match("^.+%.(.+)$")
				local opener = file_associations[ext]
				if opener then
					vim.fn.jobstart({ opener, path }, { detach = true })
				else
					vim.fn.jobstart({ "xdg-open", path }, { detach = true })
				end
			end,
			desc = "Open externally",
		},
		["<C-l>"] = false,
		["<C-h>"] = false,
		["L"] = "actions.refresh",
		["K"] = {
			function()
				if detail_popup_id and vim.api.nvim_win_is_valid(detail_popup_id) then
					vim.api.nvim_set_current_win(detail_popup_id)
					return
				end

				local oil = require("oil")
				local entry = oil.get_cursor_entry()
				local dir = oil.get_current_dir()
				if not entry or not dir then
					return
				end

				local function format_size(bytes)
					local units = { "B", "KB", "MB", "GB", "TB" }
					local i = 1
					while bytes > 1024 and i < #units do
						bytes = bytes / 1024
						i = i + 1
					end
					return string.format("%.2f %s", bytes, units[i])
				end

				local function format_mode(mode)
					local kind_map = { [32768] = "-", [16384] = "d", [40960] = "l" }
					local kind = kind_map[bit.band(mode, 61440)] or "?"
					local function perm_str(val)
						return (bit.band(val, 4) > 0 and "r" or "-")
							.. (bit.band(val, 2) > 0 and "w" or "-")
							.. (bit.band(val, 1) > 0 and "x" or "-")
					end
					local u = bit.rshift(bit.band(mode, 448), 6)
					local g = bit.rshift(bit.band(mode, 56), 3)
					local o = bit.band(mode, 7)
					return kind .. perm_str(u) .. perm_str(g) .. perm_str(o)
				end

				local path = dir .. entry.name
				local stat = vim.uv.fs_stat(path)
				if not stat then
					return
				end

				local size_label = "..."
				if entry.type == "file" then
					size_label = format_size(stat.size)
				elseif entry.type == "directory" then
					size_label = "Calculating..."
				end

				local lines = {
					"    " .. entry.name,
					"  Type:      " .. entry.type,
					"  Size:      " .. size_label,
					"  Perms:     " .. format_mode(stat.mode),
					"  Created:   " .. os.date("%Y-%m-%d %H:%M:%S", stat.birthtime.sec),
					"  Modified:  " .. os.date("%Y-%m-%d %H:%M:%S", stat.mtime.sec),
				}

				local max_width = 0
				for _, line in ipairs(lines) do
					max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
				end
				table.insert(lines, 2, string.rep("─", max_width))

				local buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
				vim.bo[buf].modifiable = false
				vim.bo[buf].bufhidden = "wipe"

				local oil_win = vim.api.nvim_get_current_win()
				local win = vim.api.nvim_open_win(buf, false, {
					relative = "cursor",
					width = max_width,
					height = #lines,
					row = 1,
					col = 0,
					style = "minimal",
					border = "none",
				})

				vim.wo[win].winblend = 15
				vim.wo[win].winhighlight = "Normal:CursorLine"
				detail_popup_id = win

				local close_win = function()
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_win_close(win, true)
					end
					detail_popup_id = nil
				end

				vim.keymap.set("n", "q", close_win, { buffer = buf })
				vim.keymap.set("n", "<Esc>", close_win, { buffer = buf })

				vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave", "TextChanged", "InsertEnter" }, {
					buffer = vim.api.nvim_win_get_buf(oil_win),
					callback = function()
						local cur_win = vim.api.nvim_get_current_win()
						if cur_win == win then
							return
						end
						if cur_win == oil_win then
							close_win()
							return true
						end
						if cur_win ~= win and cur_win ~= oil_win then
							close_win()
							return true
						end
					end,
					desc = "Close oil popup on move/change",
				})

				if entry.type == "directory" then
					local stdout_data = ""
					vim.fn.jobstart({ "du", "-sk", path }, {
						stdout_buffered = true,
						on_stdout = function(_, data)
							if data then
								stdout_data = stdout_data .. table.concat(data, "")
							end
						end,
						on_exit = function()
							if not vim.api.nvim_buf_is_valid(buf) then
								return
							end

							local kbytes = tonumber(stdout_data:match("^(%d+)"))
							local final_size = "Error"
							if kbytes then
								final_size = format_size(kbytes * 1024)
							end

							vim.schedule(function()
								if vim.api.nvim_buf_is_valid(buf) then
									vim.bo[buf].modifiable = true
									vim.api.nvim_buf_set_lines(buf, 3, 4, false, { "  Size:      " .. final_size })
									vim.bo[buf].modifiable = false
								end
							end)
						end,
					})
				end
			end,
			desc = "Peek details",
			mode = "n",
		},
		["<leader>fr"] = {
			function()
				local snacks = require("snacks")
				local path = require("oil").get_current_dir(0)
				local entry = require("oil").get_cursor_entry()
				local cwd = path
				if entry and entry.type == "directory" then
					cwd = path .. entry.parsed_name
				end
				snacks.picker.grep({ cwd = cwd })
			end,
			mode = "n",
			nowait = true,
			desc = "Snacks grep",
		},
		["gd"] = {
			function()
				require("snacks").picker.pick({
					finder = "proc",
					cmd = "fd",
					args = { "--type", "d", "--hidden", "--follow", "--exclude", ".git" },
					transform = function(item)
						item.file = item.text
						item.dir = true
					end,
					confirm = function(picker, item)
						picker:close()
						if item then
							require("oil").open(item.text)
						end
					end,
					title = "Oil Change Dir",
					layout = "vscode",
				})
			end,
			desc = "Snacks switch directory",
			mode = "n",
		},
	},
	delete_to_trash = true,
}

function M.setup()
	packadd(M.name)
	vim.keymap.set("n", "-", function()
		require("oil").open()
	end, { desc = "Open parent directory" })

	require("oil").setup(opts)
end

return M
