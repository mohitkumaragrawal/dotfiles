local M = {}

local loaded = {}

local function listify(value)
	if value == nil then
		return {}
	end

	if vim.islist(value) then
		return value
	end

	return { value }
end

function M.install(specs)
	vim.pack.add(specs, {
		load = false,
		confirm = false,
	})
end

function M.load(names)
	for _, name in ipairs(listify(names)) do
		if not loaded[name] then
			vim.cmd.packadd(name)
			loaded[name] = true
		end
	end
end

function M.once(callback)
	local done = false
	return function(...)
		if done then
			return false
		end

		done = true
		callback(...)
		return true
	end
	end

function M.on_events(events, callback, opts)
	opts = opts or {}
	vim.api.nvim_create_autocmd(events, {
		group = opts.group,
		pattern = opts.pattern,
		once = opts.once,
		callback = callback,
	})
end

function M.on_filetypes(filetypes, callback)
	local load_once = M.once(callback)
	vim.api.nvim_create_autocmd("FileType", {
		pattern = listify(filetypes),
		callback = function(ev)
			if not load_once(ev) then
				return
			end

			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].filetype == ev.match then
					vim.api.nvim_exec_autocmds("FileType", { buffer = ev.buf, modeline = false })
				end
			end)
		end,
	})
end

function M.on_vimenter(callback)
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			vim.schedule(callback)
		end,
	})
end

function M.on_cmdundefined(commands, callback)
	local load_once = M.once(callback)
	vim.api.nvim_create_autocmd("CmdUndefined", {
		pattern = listify(commands),
		callback = function()
			load_once()
		end,
	})
end

function M.register_build_hooks(builds)
	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PluginsBuildHooks", { clear = true }),
		callback = function(ev)
			local build = builds[ev.data.spec.name]
			if not build then
				return
			end

			if ev.data.kind == "install" or ev.data.kind == "update" then
				build(ev.data.path)
			end
		end,
	})
end

function M.shell_build(name, command, path)
	local result = vim.system({ vim.o.shell, vim.o.shellcmdflag, command }, {
		cwd = path,
		text = true,
	}):wait()

	if result.code ~= 0 then
		vim.notify(
			("Build failed for %s\n%s"):format(name, result.stderr or result.stdout or ""),
			vim.log.levels.ERROR
		)
	end
end

return M
