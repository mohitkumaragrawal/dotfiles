local uv = vim.uv or vim.loop

local M = {}

local STATE = {
	root_dir = "/tmp/nvim-agent-context",
	instances_dir = "/tmp/nvim-agent-context/instances",
	main_link_path = "/tmp/nvim-agent-context/main.context.md",
	legacy_main_pointer_path = "/tmp/nvim-agent-context/main.md",
	context_path = nil,
	heartbeat_path = nil,
	pid = vim.fn.getpid(),
	servername = vim.v.servername or "",
	started_cwd = nil,
	heartbeat_ttl_seconds = 15,
	debounce_ms = 200,
	write_requested = false,
	write_in_flight = false,
	write_generation = 0,
	write_timer = nil,
	flush_waiters = {},
	augroup = nil,
}

local function notify_async(message, level)
	vim.schedule(function()
		vim.notify(message, level or vim.log.levels.INFO)
	end)
end

local function utc_timestamp()
	return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function yaml_quote(value)
	local text = tostring(value or "")
	text = text:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n")
	return "\"" .. text .. "\""
end

local function yaml_value(value)
	local kind = type(value)
	if kind == "boolean" then
		return value and "true" or "false"
	end
	if kind == "number" then
		return tostring(value)
	end
	return yaml_quote(value)
end

local function md_cell(value)
	local text = tostring(value or "")
	text = text:gsub("\n", " "):gsub("|", "\\|")
	return text
end

local function is_visual_like_mode(mode)
	if not mode or mode == "" then
		return false
	end
	local first = mode:sub(1, 1)
	return first == "v" or first == "V" or first == "\22" or first == "s" or first == "S" or first == "\19"
end

local function is_enoent(err)
	return err and tostring(err):match("ENOENT") ~= nil
end

local function path_depth(path)
	local depth = 0
	for _ in tostring(path):gmatch("/") do
		depth = depth + 1
	end
	return depth
end

local function normalize_absolute_path(path)
	local full = vim.fn.fnamemodify(path, ":p")
	full = full:gsub("/+$", "")
	return full
end

local function make_display_path(abs_path, cwd)
	if not abs_path or abs_path == "" then
		return ""
	end
	if not cwd or cwd == "" then
		return abs_path
	end

	local cwd_prefix = cwd .. "/"
	if abs_path == cwd then
		return "."
	end
	if abs_path:sub(1, #cwd_prefix) == cwd_prefix then
		return abs_path:sub(#cwd_prefix + 1)
	end

	return abs_path
end

local function is_file_buffer(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	if not vim.bo[bufnr].buflisted then
		return false
	end
	if vim.bo[bufnr].buftype ~= "" then
		return false
	end

	local name = vim.api.nvim_buf_get_name(bufnr)
	if not name or name == "" then
		return false
	end

	local abs = normalize_absolute_path(name)
	if vim.fn.isdirectory(abs) == 1 then
		return false
	end

	return true
end

local function sorted_keys_numeric(map)
	local keys = {}
	for key, _ in pairs(map) do
		table.insert(keys, key)
	end
	table.sort(keys, function(a, b)
		return a < b
	end)
	return keys
end

local function create_parent_dirs()
	vim.fn.mkdir(STATE.instances_dir, "p")
end

local function format_frontmatter(meta, ordered_keys)
	local lines = { "---" }
	for _, key in ipairs(ordered_keys) do
		lines[#lines + 1] = string.format("%s: %s", key, yaml_value(meta[key]))
	end
	lines[#lines + 1] = "---"
	lines[#lines + 1] = ""
	return table.concat(lines, "\n")
end

local function render_heartbeat(snapshot)
	local meta = {
		schema_version = 1,
		pid = STATE.pid,
		servername = STATE.servername,
		updated_at = snapshot.updated_at,
		updated_unix = snapshot.updated_unix,
		stale = false,
	}

	local frontmatter = format_frontmatter(meta, {
		"schema_version",
		"pid",
		"servername",
		"updated_at",
		"updated_unix",
		"stale",
	})

	local body = table.concat({
		"# Neovim Agent Heartbeat",
		"",
		"- pid: " .. tostring(meta.pid),
		"- updated_at: " .. tostring(meta.updated_at),
		"- updated_unix: " .. tostring(meta.updated_unix),
	}, "\n")

	return frontmatter .. body .. "\n"
end

local function render_context(snapshot)
	local meta = {
		schema_version = 1,
		pid = STATE.pid,
		servername = STATE.servername,
		current_cwd = snapshot.current_cwd,
		updated_at = snapshot.updated_at,
		updated_unix = snapshot.updated_unix,
		active_file = snapshot.active_file_display,
		active_line = snapshot.active_line,
		selection_present = snapshot.selection_text ~= "",
		total_file_count = #snapshot.buffers,
		exported_file_count = math.min(10, #snapshot.buffers),
		stale = false,
	}

	local lines = {}
	lines[#lines + 1] = format_frontmatter(meta, {
		"schema_version",
		"pid",
		"servername",
		"current_cwd",
		"updated_at",
		"updated_unix",
		"active_file",
		"active_line",
		"selection_present",
		"total_file_count",
		"exported_file_count",
		"stale",
	})
	lines[#lines + 1] = "# Neovim Agent Context"
	lines[#lines + 1] = ""
	lines[#lines + 1] = "## Active"
	lines[#lines + 1] = ""
	lines[#lines + 1] = string.format("- file: `%s:%d`", snapshot.active_file_display, snapshot.active_line)
	lines[#lines + 1] = "- selection:"
	if snapshot.selection_text ~= "" then
		lines[#lines + 1] = "````text"
		lines[#lines + 1] = snapshot.selection_text
		lines[#lines + 1] = "````"
	else
		lines[#lines + 1] = "_none_"
	end
	lines[#lines + 1] = ""
	lines[#lines + 1] = "## Top Files (max 10)"
	lines[#lines + 1] = ""
	lines[#lines + 1] = "| rank | file:line | modified | visible | current |"
	lines[#lines + 1] = "| --- | --- | --- | --- | --- |"

	local limit = math.min(10, #snapshot.buffers)
	for index = 1, limit do
		local buffer = snapshot.buffers[index]
		local line_no = buffer.line or 1
		lines[#lines + 1] = string.format(
			"| %d | %s:%d | %s | %s | %s |",
			index,
			md_cell(buffer.path_display),
			line_no,
			tostring(buffer.modified),
			tostring(buffer.visible),
			tostring(buffer.current)
		)
	end

	return table.concat(lines, "\n") .. "\n"
end

local function write_atomic_async(path, content, callback)
	local tmp_path = string.format("%s.tmp.%d.%d", path, STATE.pid, uv.hrtime())

	uv.fs_open(tmp_path, "w", 420, function(open_err, fd)
		if open_err or not fd then
			callback(false, open_err)
			return
		end

		local function fail(err)
			uv.fs_close(fd, function()
				uv.fs_unlink(tmp_path, function()
					callback(false, err)
				end)
			end)
		end

		uv.fs_write(fd, content, -1, function(write_err)
			if write_err then
				fail(write_err)
				return
			end

			uv.fs_fsync(fd, function(sync_err)
				if sync_err then
					fail(sync_err)
					return
				end

				uv.fs_close(fd, function(close_err)
					if close_err then
						uv.fs_unlink(tmp_path, function()
							callback(false, close_err)
						end)
						return
					end

					uv.fs_rename(tmp_path, path, function(rename_err)
						if rename_err then
							uv.fs_unlink(tmp_path, function()
								callback(false, rename_err)
							end)
							return
						end
						callback(true, nil)
					end)
				end)
			end)
		end)
	end)
end

local function set_main_symlink_async(target_path, callback)
	local tmp_link = string.format("%s.tmp.%d.%d", STATE.main_link_path, STATE.pid, uv.hrtime())

	local function finish(ok, err)
		callback(ok, err)
	end

	local function cleanup_tmp(err)
		uv.fs_unlink(tmp_link, function()
			finish(false, err)
		end)
	end

	local function rename_tmp_to_main()
		uv.fs_rename(tmp_link, STATE.main_link_path, function(rename_err)
			if not rename_err then
				finish(true, nil)
				return
			end

			if tostring(rename_err):match("EEXIST") or tostring(rename_err):match("EPERM") then
				uv.fs_unlink(STATE.main_link_path, function(unlink_err)
					if unlink_err and not is_enoent(unlink_err) then
						cleanup_tmp(unlink_err)
						return
					end

					uv.fs_rename(tmp_link, STATE.main_link_path, function(second_rename_err)
						if second_rename_err then
							cleanup_tmp(second_rename_err)
							return
						end
						finish(true, nil)
					end)
				end)
				return
			end

			cleanup_tmp(rename_err)
		end)
	end

	uv.fs_unlink(tmp_link, function()
		uv.fs_symlink(target_path, tmp_link, function(symlink_err)
			if symlink_err then
				finish(false, symlink_err)
				return
			end

			rename_tmp_to_main()
		end)
	end)
end

local function get_visual_selection_text(bufnr)
	local mode = vim.fn.mode(1)
	local start_pos
	local end_pos

	if is_visual_like_mode(mode) then
		-- While actively selecting, use visual start (`v`) + cursor for reliable live range.
		start_pos = vim.fn.getpos("v")
		end_pos = vim.fn.getcurpos()
	else
		-- Fallback to last visual marks after leaving visual mode.
		start_pos = vim.fn.getpos("'<")
		end_pos = vim.fn.getpos("'>")
	end

	if not start_pos or not end_pos or start_pos[2] == 0 or end_pos[2] == 0 then
		return ""
	end
	if start_pos[1] ~= 0 and start_pos[1] ~= bufnr then
		return ""
	end
	if end_pos[1] ~= 0 and end_pos[1] ~= bufnr then
		return ""
	end

	local sline, scol = start_pos[2], start_pos[3]
	local eline, ecol = end_pos[2], end_pos[3]
	if (sline > eline) or (sline == eline and scol > ecol) then
		sline, eline = eline, sline
		scol, ecol = ecol, scol
	end

	local line_mode = mode:sub(1, 1) == "V" or mode:sub(1, 1) == "S"
	local lines = vim.api.nvim_buf_get_lines(bufnr, sline - 1, eline, false)
	if #lines == 0 then
		return ""
	end

	if not line_mode then
		lines[1] = lines[1]:sub(scol)
		lines[#lines] = lines[#lines]:sub(1, ecol)
	end

	local selection = table.concat(lines, "\n"):gsub("%z", "")
	if selection == "" then
		return ""
	end
	if #selection > 1000 then
		selection = selection:sub(1, 1000) .. "\n...[truncated]"
	end
	return selection
end

local function compute_snapshot()
	local snapshot = {
		updated_at = utc_timestamp(),
		updated_unix = os.time(),
		current_cwd = vim.fn.getcwd(),
		ui = {
			current_tab = vim.api.nvim_tabpage_get_number(vim.api.nvim_get_current_tabpage()),
			current_win = vim.api.nvim_get_current_win(),
			columns = vim.o.columns,
			lines = vim.o.lines,
		},
		tabs = {},
		windows = {},
		buffers = {},
	}

	local current_win = snapshot.ui.current_win
	local current_buf = vim.api.nvim_win_get_buf(current_win)
	local current_buf_name_raw = vim.api.nvim_buf_get_name(current_buf)
	local current_buf_name = current_buf_name_raw ~= "" and normalize_absolute_path(current_buf_name_raw) or ""
	local current_cursor = vim.api.nvim_win_get_cursor(current_win)
	local current_tab = snapshot.ui.current_tab

	snapshot.active_file = current_buf_name ~= "" and current_buf_name or "-"
	snapshot.active_file_display = current_buf_name ~= "" and make_display_path(current_buf_name, snapshot.current_cwd) or "-"
	snapshot.active_line = current_cursor[1] or 1
	snapshot.selection_text = get_visual_selection_text(current_buf)

	local visible_buffers = {}
	local buffer_cursor_by_bufnr = {}
	local buffer_in_current_tab = {}
	local tab_to_wins = {}

	for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
		local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
		tab_to_wins[tabnr] = {}
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
			local bufnr = vim.api.nvim_win_get_buf(win)
			if is_file_buffer(bufnr) then
				local ok_cursor, cursor = pcall(vim.api.nvim_win_get_cursor, win)
				local line = ok_cursor and cursor[1] or 1
				local col = ok_cursor and cursor[2] or 0

				visible_buffers[bufnr] = true
				buffer_cursor_by_bufnr[bufnr] = buffer_cursor_by_bufnr[bufnr] or { line = line, col = col }
				if tabnr == current_tab then
					buffer_in_current_tab[bufnr] = true
				end

				table.insert(tab_to_wins[tabnr], win)
				table.insert(snapshot.windows, {
					winid = win,
					tabnr = tabnr,
					bufnr = bufnr,
					is_current = (win == current_win),
					is_visible = true,
					cursor = { line = line, col = col },
					height = vim.api.nvim_win_get_height(win),
					width = vim.api.nvim_win_get_width(win),
				})
			end
		end
	end

	local tabnrs = sorted_keys_numeric(tab_to_wins)
	for _, tabnr in ipairs(tabnrs) do
		local wins = tab_to_wins[tabnr]
		if #wins > 0 then
			table.insert(snapshot.tabs, {
				tabnr = tabnr,
				wins = wins,
			})
		end
	end

	local file_buffers = {}
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if is_file_buffer(bufnr) then
			local info = vim.fn.getbufinfo(bufnr)[1] or {}
			local full_path = normalize_absolute_path(vim.api.nvim_buf_get_name(bufnr))
			local display_path = make_display_path(full_path, snapshot.current_cwd)
			table.insert(file_buffers, {
				bufnr = bufnr,
				path = full_path,
				path_display = display_path,
				filetype = vim.bo[bufnr].filetype or "",
				listed = vim.bo[bufnr].buflisted,
				loaded = vim.api.nvim_buf_is_loaded(bufnr),
				modified = vim.bo[bufnr].modified,
				readonly = vim.bo[bufnr].readonly,
				lastused = info.lastused or 0,
				visible = visible_buffers[bufnr] or false,
				current = (bufnr == current_buf),
				line = (buffer_cursor_by_bufnr[bufnr] and buffer_cursor_by_bufnr[bufnr].line)
					or ((info.lnum and info.lnum > 0) and info.lnum or 1),
				cursor = buffer_cursor_by_bufnr[bufnr],
				in_current_tab = buffer_in_current_tab[bufnr] or false,
				priority = 0,
			})
		end
	end

	table.sort(file_buffers, function(a, b)
		if a.lastused == b.lastused then
			return a.bufnr < b.bufnr
		end
		return a.lastused > b.lastused
	end)

	local recency_rank = {}
	local total = #file_buffers
	for index, buffer in ipairs(file_buffers) do
		recency_rank[buffer.bufnr] = total - index + 1
	end

	for _, buffer in ipairs(file_buffers) do
		local score = 0
		if buffer.current then
			score = score + 1000
		end
		if buffer.visible then
			score = score + 500
		end
		score = score + (recency_rank[buffer.bufnr] or 0)
		buffer.priority = score
	end

	table.sort(file_buffers, function(a, b)
		if a.priority ~= b.priority then
			return a.priority > b.priority
		end
		if a.in_current_tab ~= b.in_current_tab then
			return a.in_current_tab
		end
		local depth_a = path_depth(a.path)
		local depth_b = path_depth(b.path)
		if depth_a ~= depth_b then
			return depth_a < depth_b
		end
		if a.path ~= b.path then
			return a.path < b.path
		end
		return a.bufnr < b.bufnr
	end)

	snapshot.buffers = file_buffers

	return snapshot
end

local function run_waiters_until_generation(generation, ok)
	local pending = {}
	for _, waiter in ipairs(STATE.flush_waiters) do
		if waiter.generation <= generation then
			local callback_ok, callback_err = pcall(waiter.callback, ok)
			if not callback_ok then
				notify_async("agent_context: callback failed: " .. tostring(callback_err), vim.log.levels.WARN)
			end
		else
			table.insert(pending, waiter)
		end
	end
	STATE.flush_waiters = pending
end

local function finalize_write(generation, ok)
	STATE.write_in_flight = false
	run_waiters_until_generation(generation, ok)
	if STATE.write_requested then
		vim.schedule(function()
			M.flush()
		end)
	end
end

function M.flush()
	if STATE.write_in_flight then
		return
	end
	if not STATE.write_requested then
		return
	end

	STATE.write_in_flight = true
	STATE.write_requested = false
	local generation = STATE.write_generation

	local snapshot = compute_snapshot()
	local context_md = render_context(snapshot)
	local heartbeat_md = render_heartbeat(snapshot)

	write_atomic_async(STATE.context_path, context_md, function(context_ok, context_err)
		if not context_ok then
			notify_async("agent_context: failed writing context: " .. tostring(context_err), vim.log.levels.WARN)
			finalize_write(generation, false)
			return
		end

		write_atomic_async(STATE.heartbeat_path, heartbeat_md, function(heartbeat_ok, heartbeat_err)
			if not heartbeat_ok then
				notify_async("agent_context: failed writing heartbeat: " .. tostring(heartbeat_err), vim.log.levels.WARN)
			end
			finalize_write(generation, true)
		end)
	end)
end

function M.request_write(immediate, on_complete)
	STATE.write_generation = STATE.write_generation + 1
	local request_generation = STATE.write_generation
	STATE.write_requested = true

	if on_complete then
		table.insert(STATE.flush_waiters, {
			generation = request_generation,
			callback = on_complete,
		})
	end

	if immediate then
		if STATE.write_timer then
			STATE.write_timer:stop()
		end
		M.flush()
		return
	end

	if not STATE.write_timer then
		return
	end

	STATE.write_timer:stop()
	STATE.write_timer:start(
		STATE.debounce_ms,
		0,
		vim.schedule_wrap(function()
			M.flush()
		end)
	)
end

function M.set_main_context()
	M.request_write(true, function(write_ok)
		if not write_ok then
			notify_async("agent_context: failed to refresh context before setting main", vim.log.levels.WARN)
			return
		end

		set_main_symlink_async(STATE.context_path, function(link_ok, link_err)
			if not link_ok then
				notify_async("agent_context: failed to set main symlink: " .. tostring(link_err), vim.log.levels.WARN)
				return
			end
			notify_async("Main context set: " .. STATE.context_path)
		end)
	end)
end

function M.clear_main_context()
	uv.fs_unlink(STATE.main_link_path, function(err)
		if err and not is_enoent(err) then
			notify_async("agent_context: failed clearing main symlink: " .. tostring(err), vim.log.levels.WARN)
			return
		end
		notify_async("Main context cleared")
	end)
end

function M.setup(opts)
	if STATE.augroup then
		return
	end

	opts = opts or {}
	STATE.debounce_ms = opts.debounce_ms or STATE.debounce_ms
	STATE.heartbeat_ttl_seconds = opts.heartbeat_ttl_seconds or STATE.heartbeat_ttl_seconds
	STATE.started_cwd = uv.cwd() or vim.fn.getcwd()

	create_parent_dirs()

	STATE.context_path = string.format("%s/%d.context.md", STATE.instances_dir, STATE.pid)
	STATE.heartbeat_path = string.format("%s/%d.heartbeat.md", STATE.instances_dir, STATE.pid)

	STATE.write_timer = uv.new_timer()
	STATE.augroup = vim.api.nvim_create_augroup("AgentContextExporter", { clear = true })

	vim.api.nvim_create_user_command("MainContext", function()
		M.set_main_context()
	end, { desc = "Select this Neovim process as the global main AI context" })

	vim.api.nvim_create_user_command("MainContextClear", function()
		M.clear_main_context()
	end, { desc = "Clear global main AI context selection" })

	local events = {
		"BufEnter",
		"BufWinEnter",
		"BufAdd",
		"BufDelete",
		"WinEnter",
		"WinClosed",
		"TabEnter",
		"TabClosed",
		"CursorHold",
		"FocusGained",
		"VimResized",
		"DirChanged",
		"BufModifiedSet",
		"ModeChanged",
	}

	vim.api.nvim_create_autocmd(events, {
		group = STATE.augroup,
		callback = function()
			M.request_write(false)
		end,
	})

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = STATE.augroup,
		callback = function()
			if is_visual_like_mode(vim.fn.mode(1)) then
				M.request_write(false)
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = STATE.augroup,
		callback = function()
			if STATE.write_timer then
				STATE.write_timer:stop()
				STATE.write_timer:close()
				STATE.write_timer = nil
			end
		end,
	})

	uv.fs_unlink(STATE.legacy_main_pointer_path, function(_)
		-- Best-effort cleanup of deprecated pointer file.
	end)

	M.request_write(true)
end

return M
