local configure_cdm_scala_sbt = function()
	local paths = {
		project_root = "/Users/mohit/sdmain/src/java/sd",
		project_jdk = "/Users/mohit/sdmain/polaris/.buildenv/jdk",
		server_jdk = "/Users/mohit/Library/Caches/Coursier/arc/https/cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-macosx_aarch64.tar.gz/zulu17.62.17-ca-jdk17.0.17-macosx_aarch64",
		metals_bin = "/Users/mohit/Library/Application Support/Coursier/bin/metals",
		sbt_script = "/Users/mohit/sdmain/ide/vscode_workspace/cdm_scala_sbt/sbt.sh",
		scalafmt_bin = "/Users/mohit/sdmain/polaris/.buildenv/bin/scalafmt",
		scalafmt_conf = "/Users/mohit/sdmain/.scalafmt.conf",
		activate_env = "/Users/mohit/sdmain/polaris/.buildenv/bin/activate",
	}

	local metals_jvm_flags = {
		"-J-Xmx20G",
		"-J-XX:+UseZGC",
		"-J-XX:ZUncommitDelay=30",
		"-J-XX:ZCollectionInterval=5",
		"-J-XX:+IgnoreUnrecognizedVMOptions",
	}

	local metals_opts = {
		root_dir = function()
			return paths.project_root
		end,
		cmd_env = {
			JAVA_HOME = paths.server_jdk,
			PATH = paths.server_jdk .. "/bin:" .. vim.env.PATH,
		},
		init_options = {
			javaHome = paths.project_jdk,
			statusBarProvider = "off",
			isHttpEnabled = true,
			compilerOptions = { snippetAutoIndent = false },
			sbtScript = paths.sbt_script,
			scalafmtConfigPath = paths.scalafmt_conf,
			defaultBspToBuildTool = true,
		},
		cmd = vim.list_extend({ paths.metals_bin }, metals_jvm_flags),
	}

	-- vim.lsp.config["metals"] = metals_opts
	-- vim.lsp.enable("metals")

	-- require("lspconfig").metals.setup(metals_opts)

	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = "*.scala",
		callback = function(args)
			if vim.g.format_on_save == false then
				return
			end
			local file_path = args.file
			-- Exclusions
			if string.match(file_path, "%.pb%.scala$") or string.match(file_path, "_generated%.scala$") then
				return
			end

			local cmd = string.format("%s -c %s %s", paths.scalafmt_bin, paths.scalafmt_conf, file_path)

			vim.fn.jobstart(cmd, {
				on_exit = function(_, code)
					-- Reload buffer if formatting succeeded
					if code == 0 and vim.api.nvim_get_current_buf() == args.buf then
						vim.cmd("checktime")
					end
				end,
			})
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "scala",
		callback = function()
			vim.opt_local.colorcolumn = "80,120"
			vim.opt_local.expandtab = true
			vim.opt_local.shiftwidth = 2
			vim.opt_local.tabstop = 2
		end,
	})
end

local util = require("plugins.util")

local core_configured = false
local trouble_configured = false
local lazydev_configured = false

local lazydev_opts = {
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		{ path = "snacks.nvim", words = { "Snacks" } },
	},
}

local M = {
	specs = {
		{ src = "https://github.com/williamboman/mason.nvim", name = "mason.nvim" },
		{ src = "https://github.com/williamboman/mason-lspconfig.nvim", name = "mason-lspconfig.nvim" },
		{ src = "https://github.com/neovim/nvim-lspconfig", name = "nvim-lspconfig" },
		{ src = "https://github.com/folke/lazydev.nvim", name = "lazydev.nvim" },
		{ src = "https://github.com/folke/trouble.nvim", name = "trouble.nvim" },
	},
}

function M.load_core()
	if core_configured then
		return
	end

	util.load({ "mason.nvim", "mason-lspconfig.nvim", "nvim-lspconfig" })
	require("mason").setup()
	require("mason-lspconfig").setup({ auto_install = false })
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client then
				client.server_capabilities.semanticTokensProvider = nil
			end
		end,
	})
	configure_cdm_scala_sbt()
	core_configured = true
end

function M.load_lazydev()
	if lazydev_configured then
		return
	end

	util.load("lazydev.nvim")
	require("lazydev").setup(lazydev_opts)
	lazydev_configured = true
end

function M.load_trouble()
	if trouble_configured then
		return
	end

	util.load("trouble.nvim")
	require("trouble").setup({})
	trouble_configured = true
end

function M.register()
	util.on_events({ "BufReadPre", "BufNewFile" }, M.load_core, { once = true })
	util.on_cmdundefined({ "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" }, M.load_core)
	util.on_filetypes("lua", M.load_lazydev)
	util.on_cmdundefined("Trouble", M.load_trouble)

	vim.keymap.set("n", "<leader>xX", function()
		M.load_trouble()
		vim.cmd("Trouble diagnostics toggle")
	end, { desc = "Diagnostics (Trouble)" })
	vim.keymap.set("n", "<leader>xx", function()
		M.load_trouble()
		vim.cmd("Trouble diagnostics toggle filter.buf=0")
	end, { desc = "Buffer Diagnostics (Trouble)" })
	vim.keymap.set("n", "<leader>cs", function()
		M.load_trouble()
		vim.cmd("Trouble symbols toggle focus=false")
	end, { desc = "Symbols (Trouble)" })
	vim.keymap.set("n", "<leader>xL", function()
		M.load_trouble()
		vim.cmd("Trouble loclist toggle")
	end, { desc = "Location List (Trouble)" })
	vim.keymap.set("n", "<leader>xQ", function()
		M.load_trouble()
		vim.cmd("Trouble qflist toggle")
	end, { desc = "Quickfix List (Trouble)" })
end

return M
