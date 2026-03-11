local M = {}

local uv = vim.uv

local state = {
	status = "idle",
	error = nil,
	config = { repos = {} },
	repo_cache = {},
}

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "Search Profiles" })
end

local function trim(value)
	return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function is_absolute(path)
	return path:match("^/") ~= nil or path:match("^%a:[/\\]") ~= nil
end

local function normalize_path(path)
	return vim.fs.normalize(path)
end

local function resolve_relative_path(root, path)
	if type(path) ~= "string" or path == "" or is_absolute(path) then
		return path
	end
	return normalize_path(root .. "/" .. path)
end

local function current_context_path()
	local buf_name = vim.api.nvim_buf_get_name(0)
	if buf_name ~= "" and not buf_name:match("^%w[%w+.-]*://") then
		return buf_name
	end
	return uv.cwd() or vim.fn.getcwd()
end

local function find_git_root(path)
	local start = path ~= "" and path or (uv.cwd() or vim.fn.getcwd())
	local stat = uv.fs_stat(start)
	if stat and stat.type == "file" then
		start = vim.fs.dirname(start)
	end

	local git_dir = vim.fs.find(".git", {
		path = start,
		upward = true,
		type = "directory",
		limit = 1,
	})[1]
	if git_dir then
		return vim.fs.dirname(git_dir)
	end

	local git_file = vim.fs.find(".git", {
		path = start,
		upward = true,
		type = "file",
		limit = 1,
	})[1]
	if git_file then
		return vim.fs.dirname(git_file)
	end
end

local function validate_config(config)
	if config == nil then
		return { repos = {} }
	end
	if type(config) ~= "table" then
		error("local.search_profiles must return a table")
	end

	local repos = config.repos
	if repos == nil then
		config.repos = {}
		return config
	end
	if type(repos) ~= "table" then
		error("local.search_profiles.repos must be a list")
	end

	for index, repo in ipairs(repos) do
		if type(repo) ~= "table" then
			error(("search profile repo #%d must be a table"):format(index))
		end
		if type(repo.remote) ~= "string" or trim(repo.remote) == "" then
			error(("search profile repo #%d is missing a remote string"):format(index))
		end
		if repo.profiles ~= nil and type(repo.profiles) ~= "table" then
			error(("search profile repo #%d profiles must be a list"):format(index))
		end
	end

	return config
end

local function load_private_config()
	local ok, result = pcall(require, "local.search_profiles")
	if ok then
		return validate_config(result)
	end

	if result:match("module 'local%.search_profiles' not found") then
		return { repos = {} }
	end

	error(result)
end

local function matching_repo(remote)
	for _, repo in ipairs(state.config.repos or {}) do
		if repo.remote == remote then
			return repo
		end
	end
end

local function ensure_repo_cache(root)
	local cached = state.repo_cache[root]
	if cached and (cached.status == "loading" or cached.status == "ready") then
		return cached
	end

	cached = {
		status = "loading",
		root = root,
		remote = nil,
		error = nil,
	}
	state.repo_cache[root] = cached

	vim.system({ "git", "-C", root, "config", "--get", "remote.origin.url" }, { text = true }, function(result)
		vim.schedule(function()
			local repo_state = state.repo_cache[root]
			if not repo_state then
				return
			end

			if result.code ~= 0 then
				repo_state.status = "error"
				repo_state.error = trim(result.stderr) ~= "" and trim(result.stderr)
					or "Could not read remote.origin.url for " .. root
				return
			end

			local remote = trim(result.stdout)
			if remote == "" then
				repo_state.status = "error"
				repo_state.error = "remote.origin.url is empty for " .. root
				return
			end

			repo_state.status = "ready"
			repo_state.remote = remote
			repo_state.error = nil
		end)
	end)

	return cached
end

local function scope_hint(profile)
	local grep = profile.grep or {}
	if type(grep.cwd) == "string" and grep.cwd ~= "" then
		return grep.cwd
	end
	if type(grep.dirs) == "table" and #grep.dirs > 0 then
		return table.concat(grep.dirs, ", ")
	end
	return "."
end

local function profile_items(repo)
	local items = {}
	for index, profile in ipairs(repo.profiles or {}) do
		local label = profile.label or profile.id or ("Profile " .. index)
		items[#items + 1] = {
			id = profile.id,
			label = label,
			scope = scope_hint(profile),
			grep = vim.deepcopy(profile.grep or {}),
		}
	end
	return items
end

local function resolved_grep_opts(root, profile)
	local opts = vim.deepcopy(profile.grep or {})
	opts.cwd = resolve_relative_path(root, opts.cwd)

	if type(opts.dirs) == "table" then
		local dirs = {}
		for _, dir in ipairs(opts.dirs) do
			dirs[#dirs + 1] = resolve_relative_path(root, dir)
		end
		opts.dirs = dirs
	end

	if opts.cwd == nil then
		opts.cwd = root
	end

	return opts
end

local function open_profile_picker(root, profile, picker_kind)
	local opts = resolved_grep_opts(root, profile)
	if picker_kind == "files" then
		Snacks.picker.files(opts)
		return
	end
	Snacks.picker.grep(opts)
end

function M.bootstrap()
	if state.status == "loading" or state.status == "ready" then
		return
	end

	state.status = "loading"
	state.error = nil

	vim.schedule(function()
		local ok, result = pcall(load_private_config)
		if not ok then
			state.status = "error"
			state.error = result
			return
		end

		state.config = result
		state.status = "ready"
		state.error = nil

		local root = find_git_root(current_context_path())
		if root then
			ensure_repo_cache(root)
		end
	end)
end

function M.status()
	return {
		status = state.status,
		error = state.error,
		config = vim.deepcopy(state.config),
		repo_cache = vim.deepcopy(state.repo_cache),
	}
end

function M.open_picker()
	if state.status == "idle" then
		M.bootstrap()
	end

	if state.status == "loading" then
		notify("Search profiles are still loading.", vim.log.levels.INFO)
		return
	end

	if state.status == "error" then
		notify(state.error or "Search profiles failed to load.", vim.log.levels.ERROR)
		return
	end

	if #(state.config.repos or {}) == 0 then
		notify("No private search profiles configured.", vim.log.levels.INFO)
		return
	end

	local root = find_git_root(current_context_path())
	if not root then
		notify("No git repo detected for the current context.", vim.log.levels.WARN)
		return
	end

	local repo_state = ensure_repo_cache(root)
	if repo_state.status == "loading" then
		notify("Search profiles are still loading.", vim.log.levels.INFO)
		return
	end

	if repo_state.status == "error" then
		notify(repo_state.error or "Could not determine the current repo remote.", vim.log.levels.ERROR)
		return
	end

	local repo = matching_repo(repo_state.remote)
	if not repo then
		notify("No search profile set matches this repository.", vim.log.levels.INFO)
		return
	end

	local items = profile_items(repo)
	if #items == 0 then
		notify("The matched repository has no search profiles.", vim.log.levels.INFO)
		return
	end

	Snacks.picker.select(items, {
		prompt = "Search Profiles",
		format_item = function(item)
			return ("%s  [%s]"):format(item.label, item.scope)
		end,
		snacks = {
			actions = {
				open_files = function(picker, item)
					item = item or picker:current()
					item = item and (item.item or item)
					if not item then
						return
					end
					picker:close()
					vim.schedule(function()
						open_profile_picker(root, item, "files")
					end)
				end,
			},
				win = {
					input = {
						keys = {
							["<c-f>"] = { "open_files", mode = { "n", "i" }, desc = "Find Files In Profile" },
						},
					},
				},
		},
	}, function(item)
		if not item then
			return
		end
		open_profile_picker(root, item, "grep")
	end)
end

return M
