local M = {}

local registry = {}
local loaded = {}
local loading = {}

local function listify(value)
	if value == nil then
		return {}
	end

	if vim.islist(value) then
		return value
	end

	return { value }
end

local function plugin_name(repo)
	local name = repo:match("/([^/]+)$") or repo
	return name:gsub("%.git$", "")
end

local function plugin_src(repo)
	if repo:match("^[%w+.-]+://") or repo:match("^git@") then
		return repo
	end

	return "https://github.com/" .. repo
end

local function normalize_version(version)
	if type(version) == "string" and version:find("[%*<>=~%^]") then
		local ok, range = pcall(vim.version.range, version)
		if ok then
			return range
		end
	end

	return version
end

local function infer_main(spec)
	if spec.main then
		return spec.main
	end

	local main = spec.name
	if main == "nvim-notify" then
		return "notify"
	end

	main = main:gsub("%.nvim$", "")
	main = main:gsub("%.lua$", "")
	return main
end

local function default_config(spec)
	if spec.opts == nil then
		return
	end

	local main = infer_main(spec)
	local ok, plugin = pcall(require, main)
	if ok and type(plugin.setup) == "function" then
		plugin.setup(spec.opts)
	end
end

local function create_spec(raw)
	if raw.enabled == false then
		return nil
	end

	local repo = raw[1] or raw.src
	if type(repo) ~= "string" then
		return nil
	end

	local name = raw.name or plugin_name(repo)

	return {
		src = raw.src or plugin_src(repo),
		name = name,
		version = normalize_version(raw.version),
		priority = raw.priority or 0,
		dependencies = {},
		raw_dependencies = raw.dependencies,
		lazy = raw.lazy,
		event = raw.event,
		cmd = raw.cmd,
		ft = raw.ft,
		keys = raw.keys,
		init = raw.init,
		config = raw.config,
		opts = raw.opts,
		main = raw.main,
		build = raw.build,
	}
end

local function is_single_spec(specs)
	return type(specs) == "table" and (type(specs[1]) == "string" or type(specs.src) == "string")
end

local function load_module_specs(module_name)
	local ok, specs = pcall(require, module_name)
	if not ok then
		error(specs)
	end

	if is_single_spec(specs) then
		return { specs }
	end

	return specs
end

local function dependency_name(dep)
	if type(dep) == "string" then
		return plugin_name(dep)
	end

	local repo = dep[1] or dep.src
	if dep.name then
		return dep.name
	end

	return repo and plugin_name(repo) or nil
end

local function ensure_dependency(dep)
	if type(dep) == "string" then
		dep = { dep }
	end

	local name = dependency_name(dep)
	if not name then
		return nil
	end

	if registry[name] then
		return registry[name]
	end

	local spec = create_spec(dep)
	if spec then
		registry[name] = spec
		return spec
	end

	return nil
end

local function startup_plugin(spec)
	local has_trigger = spec.event ~= nil or spec.cmd ~= nil or spec.ft ~= nil or spec.keys ~= nil
	return spec.lazy == false or not has_trigger
end

local function map_modes(mode)
	if mode == nil then
		return "n"
	end

	if mode == "" then
		return { "n", "v" }
	end

	return mode
end

local function run_build(spec, path)
	local build = spec.build
	if build == nil then
		return
	end

	if type(build) == "function" then
		build(spec)
		return
	end

	if type(build) ~= "string" then
		return
	end

	if build:sub(1, 1) == ":" then
		M.load(spec.name)
		vim.cmd(build:sub(2))
		return
	end

	local result = vim.system({ vim.o.shell, vim.o.shellcmdflag, build }, {
		cwd = path,
		text = true,
	}):wait()

	if result.code ~= 0 then
		vim.notify(
			("Build failed for %s\n%s"):format(spec.name, result.stderr or result.stdout or ""),
			vim.log.levels.ERROR
		)
	end
end

function M.load(name)
	local spec = registry[name]
	if not spec or loaded[name] or loading[name] then
		return
	end

	loading[name] = true

	for _, dep_name in ipairs(spec.dependencies) do
		M.load(dep_name)
	end

	vim.cmd.packadd(spec.name)

	if not spec.configured then
		if type(spec.config) == "function" then
			spec.config(spec, spec.opts)
		else
			default_config(spec)
		end
		spec.configured = true
	end

	loaded[name] = true
	loading[name] = nil
end

local function register_commands(spec)
	local commands = listify(spec.cmd)
	if #commands == 0 then
		return
	end

	vim.api.nvim_create_autocmd("CmdUndefined", {
		group = vim.api.nvim_create_augroup("PluginLoaderCmd" .. spec.name, { clear = true }),
		pattern = commands,
		once = true,
		callback = function()
			M.load(spec.name)
		end,
	})
end

local function register_events(spec)
	local events = listify(spec.event)
	if #events == 0 then
		return
	end

	local patterns = {}
	local normal_events = {}
	for _, event in ipairs(events) do
		if event == "VeryLazy" then
			table.insert(normal_events, "User")
			table.insert(patterns, "VeryLazy")
		else
			table.insert(normal_events, event)
		end
	end

	local opts = {
		group = vim.api.nvim_create_augroup("PluginLoaderEvent" .. spec.name, { clear = true }),
		once = true,
		callback = function()
			M.load(spec.name)
		end,
	}

	if #patterns > 0 then
		opts.pattern = patterns
	end

	vim.api.nvim_create_autocmd(normal_events, opts)
end

local function register_filetypes(spec)
	local filetypes = listify(spec.ft)
	if #filetypes == 0 then
		return
	end

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("PluginLoaderFt" .. spec.name, { clear = true }),
		pattern = filetypes,
		once = true,
		callback = function(ev)
			M.load(spec.name)
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].filetype == ev.match then
					vim.api.nvim_exec_autocmds("FileType", { buffer = ev.buf, modeline = false })
				end
			end)
		end,
	})
end

local function register_keys(spec)
	for _, key in ipairs(listify(spec.keys)) do
		local lhs = key[1]
		local rhs = key[2]
		if lhs and rhs then
			vim.keymap.set(map_modes(key.mode), lhs, function()
				M.load(spec.name)
				if type(rhs) == "function" then
					return rhs()
				end
				if type(rhs) == "string" then
					vim.api.nvim_feedkeys(vim.keycode(rhs), "m", false)
				end
			end, {
				desc = key.desc,
				nowait = key.nowait,
				silent = key.silent,
				expr = key.expr,
				remap = key.remap,
			})
		end
	end
end

local function discover_specs()
	local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"
	local files = vim.fn.readdir(plugin_dir, function(name)
		return name:sub(-4) == ".lua"
	end)
	table.sort(files)

	for _, file in ipairs(files) do
		local module_name = "plugins." .. file:gsub("%.lua$", "")
		for _, raw in ipairs(load_module_specs(module_name)) do
			local spec = create_spec(raw)
			if spec then
				registry[spec.name] = spec
			end
		end
	end

	for _, spec in pairs(registry) do
		for _, dep in ipairs(listify(spec.raw_dependencies)) do
			local dep_spec = ensure_dependency(dep)
			if dep_spec then
				table.insert(spec.dependencies, dep_spec.name)
			end
		end
	end
end

local function register_build_hooks()
	vim.api.nvim_create_autocmd("PackChanged", {
		group = vim.api.nvim_create_augroup("PluginLoaderBuild", { clear = true }),
		callback = function(ev)
			local spec = registry[ev.data.spec.name]
			if not spec or not spec.build then
				return
			end

			if ev.data.kind == "install" or ev.data.kind == "update" then
				run_build(spec, ev.data.path)
			end
		end,
	})
end

function M.setup()
	discover_specs()
	register_build_hooks()

	local install_specs = {}
	for _, spec in pairs(registry) do
		if type(spec.init) == "function" then
			spec.init()
		end

		table.insert(install_specs, {
			src = spec.src,
			name = spec.name,
			version = spec.version,
		})
	end

	table.sort(install_specs, function(left, right)
		return left.name < right.name
	end)

	vim.pack.add(install_specs, {
		load = false,
		confirm = false,
	})

	local startup = {}
	for _, spec in pairs(registry) do
		register_commands(spec)
		register_events(spec)
		register_filetypes(spec)
		register_keys(spec)

		if startup_plugin(spec) then
			table.insert(startup, spec)
		end
	end

	table.sort(startup, function(left, right)
		if left.priority == right.priority then
			return left.name < right.name
		end
		return left.priority > right.priority
	end)

	for _, spec in ipairs(startup) do
		M.load(spec.name)
	end

	vim.api.nvim_create_autocmd("VimEnter", {
		group = vim.api.nvim_create_augroup("PluginLoaderVeryLazy", { clear = true }),
		once = true,
		callback = function()
			vim.schedule(function()
				vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
			end)
		end,
	})
end

return M
