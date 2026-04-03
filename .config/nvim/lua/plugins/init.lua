local lualine = require("plugins.lualine")
local oil = require("plugins.oil")
local theme = require("plugins.theme")

local M = {}
local added = {}
local loaded = {}
local configured = {}

local plugin_specs = {
  { src = "https://github.com/nvim-tree/nvim-web-devicons",               name = "nvim-web-devicons" },
  { src = "https://github.com/github/copilot.vim",                        name = "copilot.vim" },
  { src = "https://github.com/rafamadriz/friendly-snippets",              name = "friendly-snippets" },
  { src = "https://github.com/saghen/blink.cmp",                          name = "blink.cmp",            version = vim.version.range("1.*") },
  { src = "https://github.com/j-hui/fidget.nvim",                         name = "fidget.nvim" },
  { src = "https://github.com/stevearc/conform.nvim",                     name = "conform.nvim" },
  { src = "https://github.com/tpope/vim-fugitive",                        name = "vim-fugitive" },
  { src = "https://github.com/tpope/vim-rhubarb",                         name = "vim-rhubarb" },
  { src = "https://github.com/lewis6991/gitsigns.nvim",                   name = "gitsigns.nvim" },
  { src = "https://github.com/lukas-reineke/indent-blankline.nvim",       name = "indent-blankline.nvim" },
  { src = "https://github.com/williamboman/mason.nvim",                   name = "mason.nvim" },
  { src = "https://github.com/williamboman/mason-lspconfig.nvim",         name = "mason-lspconfig.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig",                     name = "nvim-lspconfig" },
  { src = "https://github.com/folke/lazydev.nvim",                        name = "lazydev.nvim" },
  { src = "https://github.com/folke/trouble.nvim",                        name = "trouble.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim",                 name = "lualine.nvim" },
  { src = "https://github.com/iamcco/markdown-preview.nvim",              name = "markdown-preview.nvim" },
  { src = "https://github.com/nvim-mini/mini.nvim",                       name = "mini.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim", name = "render-markdown.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim",                      name = "nui.nvim" },
  { src = "https://github.com/folke/noice.nvim",                          name = "noice.nvim" },
  { src = "https://github.com/rcarriga/nvim-notify",                      name = "nvim-notify" },
  { src = "https://github.com/stevearc/oil.nvim",                         name = "oil.nvim" },
  { src = "https://github.com/folke/snacks.nvim",                         name = "snacks.nvim" },
  { src = "https://github.com/rebelot/kanagawa.nvim",                     name = "kanagawa.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",           name = "nvim-treesitter" },
  { src = "https://github.com/tpope/vim-commentary",                      name = "vim-commentary" },
  { src = "https://github.com/tpope/vim-surround",                        name = "vim-surround" },
  { src = "https://github.com/christoomey/vim-tmux-navigator",            name = "vim-tmux-navigator" },
}

local startup_plugin_names = {
	"nvim-web-devicons",
	"kanagawa.nvim",
	"vim-tmux-navigator",
	"vim-fugitive",
	"vim-rhubarb",
	"vim-commentary",
	"vim-surround",
	"lualine.nvim",
}

local plugin_specs_by_name = {}
for _, spec in ipairs(plugin_specs) do
	plugin_specs_by_name[spec.name] = spec
end

local markdown_info_string_aliases = {
  ex = "elixir",
  pl = "perl",
  sh = "bash",
  uxn = "uxntal",
  ts = "typescript",
}

local completion_opts = {
  enabled = function()
    if vim.fn.getcmdtype() ~= "" then
      return true
    end

    return not vim.tbl_contains({ "oil", "txt", "markdown", "md" }, vim.bo.filetype)
  end,
  keymap = { preset = "enter" },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = { documentation = { auto_show = false } },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true },
}

local formatter_opts = {
  formatters_by_ft = {
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescriptreact = { "prettierd" },
    css = { "prettierd" },
    html = { "prettierd" },
    json = { "prettierd" },
    yaml = { "prettierd" },
    markdown = { "prettierd" },
    lua = { "stylua" },
    python = { "ruff" },
    c = { "clang-format" },
    cpp = { "clang-format" },
  },
  format_on_save = function()
    if vim.g.format_on_save == false then
      return
    end

    return {
      timeout_ms = 500,
      lsp_fallback = true,
    }
  end,
}

local gitsigns_opts = {
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "" },
    untracked = { text = "▎" },
  },
  signcolumn = true,
  linehl = false,
  word_diff = false,
  current_line_blame = true,
  on_attach = function(bufnr)
    local gs = require("gitsigns")

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = bufnr,
        desc = desc,
      })
    end

    map("n", "gn", function()
      gs.nav_hunk("next")
    end, "Next hunk")
    map("n", "gp", function()
      gs.nav_hunk("prev")
    end, "Prev hunk")
    map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
    map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
    map("n", "<leader>gb", function()
      gs.blame_line({ full = true })
    end, "Show blame")
    map("n", "<leader>gd", gs.diffthis, "Show diff")
    map("n", "<leader>gD", function()
      gs.diffthis("~")
    end, "Show diff against base")
    map("n", "<leader>gh", gs.preview_hunk, "Preview hunk")
    map("n", "<leader>gt", gs.toggle_signs, "Toggle gitsigns")
    map("n", "<leader>gv", gs.toggle_current_line_blame, "Toggle blame")
  end,
}

local lazydev_opts = {
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    { path = "snacks.nvim",        words = { "Snacks" } },
  },
}

local notify_opts = {
  render = "wrapped-compact",
  fps = 60,
  timeout = 1000,
  stages = "fade",
  top_down = false,
}

local noice_opts = {
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    signature = {
      enabled = false,
    },
    hover = {
      silent = true,
      opts = {
        win_options = {
          winhighlight = {
            Normal = "LspHoverNormal",
            FloatBorder = "LspHoverBorder",
          },
        },
      },
    },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = false,
  },
}

local snacks_opts = {
  picker = {
    main = {
      file = false,
    },
  },
  dashboard = {
    enabled = false,
  },
}

local snacks_keys = {
  { "<leader><space>", function() require("snacks").picker.smart() end,                                                     desc = "Smart Find Files" },
  { "<leader>,",       function() require("snacks").picker.buffers() end,                                                   desc = "Buffers" },
  { "<leader>/",       function() require("snacks").picker.grep() end,                                                      desc = "Grep" },
  { "<leader>:",       function() require("snacks").picker.command_history() end,                                           desc = "Command History" },
  { "<leader>n",       function() require("snacks").picker.notifications() end,                                             desc = "Notification History" },
  { "<leader>fc",      function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") }) end,                   desc = "Find Config File" },
  { "<leader>ff",      function() require("snacks").picker.files() end,                                                     desc = "Find Files" },
  { "<leader>fg",      function() require("snacks").picker.git_files() end,                                                 desc = "Find Git Files" },
  { "<leader>fp",      function() require("snacks").picker.projects() end,                                                  desc = "Projects" },
  { "<leader>fr",      function() require("snacks").picker.recent() end,                                                    desc = "Recent" },
  { "<leader>fs",      function() require("search_profiles").open_picker() end,                                             desc = "Search Profiles" },
  { "<leader>fa",      function() require("snacks").picker() end,                                                           desc = "Choose Picker" },
  { "<leader>sb",      function() require("snacks").picker.lines() end,                                                     desc = "Buffer Lines" },
  { "<leader>sB",      function() require("snacks").picker.grep_buffers() end,                                              desc = "Grep Open Buffers" },
  { '<leader>s"',      function() require("snacks").picker.registers() end,                                                 desc = "Registers" },
  { "<leader>s/",      function() require("snacks").picker.search_history() end,                                            desc = "Search History" },
  { "<leader>sa",      function() require("snacks").picker.autocmds() end,                                                  desc = "Autocmds" },
  { "<leader>sc",      function() require("snacks").picker.command_history() end,                                           desc = "Command History" },
  { "<leader>sC",      function() require("snacks").picker.commands() end,                                                  desc = "Commands" },
  { "<leader>sd",      function() require("snacks").picker.diagnostics() end,                                               desc = "Diagnostics" },
  { "<leader>sD",      function() require("snacks").picker.diagnostics_buffer() end,                                        desc = "Buffer Diagnostics" },
  { "<leader>sh",      function() require("snacks").picker.help() end,                                                      desc = "Help Pages" },
  { "<leader>sH",      function() require("snacks").picker.highlights() end,                                                desc = "Highlights" },
  { "<leader>si",      function() require("snacks").picker.icons() end,                                                     desc = "Icons" },
  { "<leader>sj",      function() require("snacks").picker.jumps() end,                                                     desc = "Jumps" },
  { "<leader>sk",      function() require("snacks").picker.keymaps() end,                                                   desc = "Keymaps" },
  { "<leader>sl",      function() require("snacks").picker.loclist() end,                                                   desc = "Location List" },
  { "<leader>sm",      function() require("snacks").picker.marks() end,                                                     desc = "Marks" },
  { "<leader>sM",      function() require("snacks").picker.man() end,                                                       desc = "Man Pages" },
  { "<leader>sp",      function() require("snacks").picker.files({ cwd = vim.fn.stdpath("config") .. "/lua/plugins" }) end, desc = "Plugin Config" },
  { "<leader>sq",      function() require("snacks").picker.qflist() end,                                                    desc = "Quickfix List" },
  { "<leader>sR",      function() require("snacks").picker.resume() end,                                                    desc = "Resume" },
  { "<leader>su",      function() require("snacks").picker.undo() end,                                                      desc = "Undo History" },
  { "<leader>uC",      function() require("snacks").picker.colorschemes() end,                                              desc = "Colorschemes" },
  { "gd",              function() require("snacks").picker.lsp_definitions() end,                                           desc = "Goto Definition" },
  { "gD",              function() require("snacks").picker.lsp_declarations() end,                                          desc = "Goto Declaration" },
  { "gr",              function() require("snacks").picker.lsp_references() end,                                            nowait = true,                  desc = "References" },
  { "gI",              function() require("snacks").picker.lsp_implementations() end,                                       desc = "Goto Implementation" },
  { "gy",              function() require("snacks").picker.lsp_type_definitions() end,                                      desc = "Goto T[y]pe Definition" },
  { "gai",             function() require("snacks").picker.lsp_incoming_calls() end,                                        desc = "C[a]lls Incoming" },
  { "gao",             function() require("snacks").picker.lsp_outgoing_calls() end,                                        desc = "C[a]lls Outgoing" },
  { "<leader>ss",      function() require("snacks").picker.lsp_symbols() end,                                               desc = "LSP Symbols" },
  { "<leader>sS",      function() require("snacks").picker.lsp_workspace_symbols() end,                                     desc = "LSP Workspace Symbols" },
}

local treesitter_opts = {
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  ensure_installed = {
    "c", "cpp", "python", "lua", "vimdoc", "html", "javascript", "css",
    "scala", "typescript", "tsx", "json", "go", "yaml", "markdown", "markdown_inline",
    "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore",
  },
  auto_install = false,
}

local function listify(value)
  if value == nil then
    return {}
  end

  if vim.islist(value) then
    return value
  end

  return { value }
end

local function load_plugins(names)
  for _, name in ipairs(listify(names)) do
    if not added[name] then
      local spec = plugin_specs_by_name[name]
      if spec then
        vim.pack.add({ spec }, {
          load = false,
          confirm = false,
        })
        added[name] = true
      end
    end

    if not loaded[name] then
      vim.cmd.packadd(name)
      loaded[name] = true
    end
  end
end

local function setup_once(key, names, callback)
  if configured[key] then
    return
  end

  load_plugins(names)
  callback()
  configured[key] = true
end

local function once(callback)
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

local function on_events(events, callback, opts)
  opts = opts or {}
  vim.api.nvim_create_autocmd(events, {
    group = opts.group,
    pattern = opts.pattern,
    once = opts.once,
    callback = callback,
  })
end

local function on_filetypes(filetypes, callback)
  local load_once = once(callback)
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

local function on_vimenter(callback)
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(callback)
    end,
  })
end

local function on_cmdundefined(commands, callback)
  local load_once = once(callback)
  vim.api.nvim_create_autocmd("CmdUndefined", {
    pattern = listify(commands),
    callback = function()
      load_once()
    end,
  })
end

local function register_build_hooks(builds)
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

local function shell_build(name, command, path)
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

local load_treesitter

local function patch_treesitter_injection_directives()
  local query = require("vim.treesitter.query")
  local directive_opts = vim.fn.has("nvim-0.10") == 1 and { force = true, all = false } or true
  local first_capture_node = function(node)
    if type(node) ~= "table" then
      return node
    end

    return node[1]
  end

  query.add_directive("set-lang-from-info-string!", function(match, _, source, pred, metadata)
    local node = first_capture_node(match[pred[2]])
    if not node then
      return
    end

    local alias = vim.treesitter.get_node_text(node, source):lower()
    local filetype = vim.filetype.match({ filename = "a." .. alias })
    metadata["injection.language"] = filetype or markdown_info_string_aliases[alias] or alias
  end, directive_opts)

  query.add_directive("set-lang-from-mimetype!", function(match, _, source, pred, metadata)
    local node = first_capture_node(match[pred[2]])
    if not node then
      return
    end

    local text = vim.treesitter.get_node_text(node, source)
    local configured_types = {
      ["importmap"] = "json",
      ["module"] = "javascript",
      ["application/ecmascript"] = "javascript",
      ["text/ecmascript"] = "javascript",
    }
    local language = configured_types[text]
    if language then
      metadata["injection.language"] = language
      return
    end

    local parts = vim.split(text, "/", {})
    metadata["injection.language"] = parts[#parts]
  end, directive_opts)
end

local function configure_cdm_scala_sbt()
  local paths = {
    project_root = "/Users/mohit/sdmain/src/java/sd",
    project_jdk = "/Users/mohit/sdmain/polaris/.buildenv/jdk",
    server_jdk =
    "/Users/mohit/Library/Caches/Coursier/arc/https/cdn.azul.com/zulu/bin/zulu17.62.17-ca-jdk17.0.17-macosx_aarch64.tar.gz/zulu17.62.17-ca-jdk17.0.17-macosx_aarch64",
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

  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.scala",
    callback = function(args)
      if vim.g.format_on_save == false then
        return
      end

      local file_path = args.file
      if string.match(file_path, "%.pb%.scala$") or string.match(file_path, "_generated%.scala$") then
        return
      end

      local cmd = string.format("%s -c %s %s", paths.scalafmt_bin, paths.scalafmt_conf, file_path)
      vim.fn.jobstart(cmd, {
        on_exit = function(_, code)
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

local function setup_notify()
  setup_once("notify", "nvim-notify", function()
    require("notify").setup(notify_opts)
  end)
end

local function setup_theme()
  theme.setup(setup_once)
end

local function setup_tmux_navigator()
  load_plugins("vim-tmux-navigator")
end

local function setup_snacks()
  setup_once("snacks", "snacks.nvim", function()
    require("snacks").setup(snacks_opts)
  end)
end

local function setup_oil()
  oil.setup(setup_once)
end

load_treesitter = function()
  setup_once("treesitter", "nvim-treesitter", function()
    patch_treesitter_injection_directives()
    require("nvim-treesitter.configs").setup(treesitter_opts)
  end)
end

local function setup_indent_blankline()
  setup_once("indent-blankline", "indent-blankline.nvim", function()
    require("ibl").setup({
      indent = {
        char = "▏",
      },
    })
  end)
end

local function setup_formatter()
  setup_once("formatter", "conform.nvim", function()
    require("conform").setup(formatter_opts)
  end)
end

local function setup_gitsigns()
  setup_once("gitsigns", "gitsigns.nvim", function()
    require("gitsigns").setup(gitsigns_opts)
  end)
end

local function setup_commentary()
  load_plugins("vim-commentary")
end

local function setup_surround()
  load_plugins("vim-surround")
end

local function setup_lualine()
  lualine.setup(setup_once)
end

local function setup_copilot()
  load_plugins("copilot.vim")
end

local function setup_completion()
  setup_once("completion", { "friendly-snippets", "blink.cmp" }, function()
    require("blink.cmp").setup(completion_opts)
  end)
end

local function setup_fidget()
  setup_once("fidget", "fidget.nvim", function()
    require("fidget").setup({})
  end)
end

local function setup_lsp_core()
  setup_once("lsp-core", { "mason.nvim", "mason-lspconfig.nvim", "nvim-lspconfig" }, function()
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
  end)
end

local function setup_lazydev()
  setup_once("lazydev", "lazydev.nvim", function()
    require("lazydev").setup(lazydev_opts)
  end)
end

local function setup_trouble()
  setup_once("trouble", "trouble.nvim", function()
    require("trouble").setup({})
  end)
end

local function setup_markdown_preview()
  load_plugins("markdown-preview.nvim")
end

local function setup_markdown_render()
  setup_once("render-markdown", { "mini.nvim", "render-markdown.nvim" }, function()
    require("render-markdown").setup({})
  end)
end

local function setup_noice()
  setup_once("noice", { "nui.nvim", "noice.nvim" }, function()
    setup_notify()
    require("noice").setup(noice_opts)
  end)
end

local function setup_fugitive()
  load_plugins({ "vim-fugitive", "vim-rhubarb" })
end

local build_hooks = {
  ["markdown-preview.nvim"] = function(path)
    shell_build("markdown-preview.nvim", "cd app && npm install", path)
  end,
  ["nvim-treesitter"] = function()
    load_treesitter()
    vim.cmd("TSUpdate")
  end,
}

local function setup_init_state()
  vim.g.tmux_navigator_no_mappings = 1
  vim.g.mkdp_filetypes = { "markdown" }
  vim.g.format_on_save = false

  vim.api.nvim_create_user_command("FormatOnSaveToggle", function()
    vim.g.format_on_save = not vim.g.format_on_save
    if vim.g.format_on_save then
      setup_formatter()
      vim.notify("Formatting on save enabled")
    else
      vim.notify("Formatting on save disabled")
    end
  end, {})

  vim.o.formatexpr = "v:lua.require'plugins'.formatexpr()"
  vim.keymap.set({ "n", "v" }, "<leader>cf", function()
    setup_formatter()
    require("conform").format({ async = true, lsp_fallback = true })
  end, { desc = "Format buffer" })
end

local function register_deferred_plugins()
  on_events("InsertEnter", setup_copilot, { once = true })
  on_events({ "InsertEnter", "CmdlineEnter" }, setup_completion, { once = true })
  on_events("LspAttach", setup_fidget, { once = true })
  on_events({ "BufReadPre", "BufNewFile" }, function()
    load_treesitter()
    setup_indent_blankline()
  end, { once = true })
  on_events({ "BufReadPre", "BufNewFile" }, setup_gitsigns, { once = true })
  on_events({ "BufReadPre", "BufNewFile" }, setup_lsp_core, { once = true })
  on_cmdundefined({ "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate" }, setup_lsp_core)
  on_cmdundefined("ConformInfo", setup_formatter)
  on_cmdundefined("Oil", setup_oil)
  on_filetypes("lua", setup_lazydev)
  on_cmdundefined("Trouble", setup_trouble)
  on_cmdundefined({ "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" }, setup_markdown_preview)
  on_filetypes({ "markdown", "mdx" }, setup_markdown_render)
  on_vimenter(setup_noice)

  for _, key in ipairs(snacks_keys) do
    vim.keymap.set(key.mode or "n", key[1], function()
      setup_snacks()
      return key[2]()
    end, {
      desc = key.desc,
      nowait = key.nowait,
    })
  end

  vim.keymap.set("n", "<leader>xX", function()
    setup_trouble()
    vim.cmd("Trouble diagnostics toggle")
  end, { desc = "Diagnostics (Trouble)" })
  vim.keymap.set("n", "<leader>xx", function()
    setup_trouble()
    vim.cmd("Trouble diagnostics toggle filter.buf=0")
  end, { desc = "Buffer Diagnostics (Trouble)" })
  vim.keymap.set("n", "<leader>cs", function()
    setup_trouble()
    vim.cmd("Trouble symbols toggle focus=false")
  end, { desc = "Symbols (Trouble)" })
  vim.keymap.set("n", "<leader>xL", function()
    setup_trouble()
    vim.cmd("Trouble loclist toggle")
  end, { desc = "Location List (Trouble)" })
  vim.keymap.set("n", "<leader>xQ", function()
    setup_trouble()
    vim.cmd("Trouble qflist toggle")
  end, { desc = "Quickfix List (Trouble)" })
end

function M.setup()
  setup_init_state()
  register_build_hooks(build_hooks)

	local startup_specs = {}
	for _, name in ipairs(startup_plugin_names) do
		local spec = plugin_specs_by_name[name]
		if spec then
			table.insert(startup_specs, spec)
			added[name] = true
		end
	end

  vim.pack.add(startup_specs, {
    load = false,
    confirm = false,
  })

  load_plugins("nvim-web-devicons")
  setup_theme()
  setup_tmux_navigator()
  setup_commentary()
  setup_surround()
  setup_lualine()
  register_deferred_plugins()
end

function M.formatexpr()
  setup_formatter()
  return require("conform").formatexpr()
end

return M
