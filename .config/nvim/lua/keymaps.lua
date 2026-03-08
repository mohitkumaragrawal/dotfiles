local M = vim.keymap.set

M("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
M("n", "<leader>-", "<cmd>split<cr>", { desc = "Split window horizontally" })
M({ "n", "v" }, "<C-h>", "<C-w>h", { desc = "Move to left window" })
M({ "n", "v" }, "<C-j>", "<C-w>j", { desc = "Move to below window" })
M({ "n", "v" }, "<C-k>", "<C-w>k", { desc = "Move to above window" })
M({ "n", "v" }, "<C-l>", "<C-w>l", { desc = "Move to right window" })
M("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close window" })
M("n", "<C-Up>", ":resize +2<CR>", { noremap = true, silent = true, desc = "Increase height" })
M("n", "<C-Down>", ":resize -2<CR>", { noremap = true, silent = true, desc = "Decrease height" })
M("n", "<C-,>", ":vertical resize -2<CR>", { noremap = true, silent = true, desc = "Increase width" })
M("n", "<C-.>", ":vertical resize +2<CR>", { noremap = true, silent = true, desc = "Decrease width" })
M("v", "<C-c>", '"+y', { desc = "Copy to system clipboard" })
-- M("n", "<C-a>", 'mzggVG"+y`zzz', { desc = "Copy whole file" })
M("n", "J", "mzJ`z", { desc = "Merge bottom line" })
M("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll up" })
M("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down" })

M("n", "<esc><esc>", ":noh<CR>", { silent = true, nowait = true })
M("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
M("n", "j", "gj", { desc = "Move down" })
M("n", "k", "gk", { desc = "Move down" })

-- M("n", "gd", vim.lsp.buf.definition, {})
-- M("n", "gr", vim.lsp.buf.references, {})
M("n", "<leader>cr", vim.lsp.buf.rename, {})

-- Copy file paths
M("n", "<leader>xp", function()
	local file_path = vim.fn.expand("%")
	vim.fn.setreg("+", file_path)
	print("Copied file path: " .. file_path)
end, { desc = "Copy file path" })

local function toggle_diagnostics_virtual_text()
	local new_config = not vim.diagnostic.config().virtual_text
	vim.diagnostic.config({
		virtual_text = new_config,
		-- You can also toggle other diagnostic displays here, like signs
		-- signs = new_config,
	})
end

M("n", "<leader>d", toggle_diagnostics_virtual_text, { desc = "Toggle diagnostics" })

-- LSP configs
M("n", "K", function()
	vim.lsp.buf.hover()
end, { desc = "Hover doc" })

M("n", "<leader>ca", function ()
  vim.lsp.buf.code_action()
end, { desc = "Hover doc" })

M("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- DAP
-- M("n", "<F5>", '<cmd>lua require("dap").continue()<cr>', { desc = "DAP: Continue" })
-- M("n", "<F6>", '<cmd>lua require("dap").terminate()<cr>', { desc = "DAP: Terminate" })
-- M("n", "<F10>", '<cmd>lua require("dap").step_over()<cr>', { desc = "DAP: Step Over" })
-- M("n", "<F11>", '<cmd>lua require("dap").step_into()<cr>', { desc = "DAP: Step Into" })
-- M("n", "<F12>", '<cmd>lua require("dap").step_out()<cr>', { desc = "DAP: Step Out" })
-- M("n", "<leader>b", '<cmd>lua require("dap").toggle_breakpoint()<cr>', { desc = "DAP: Toggle Breakpoint" })
-- M(
-- 	"n",
-- 	"<leader>B",
-- 	'<cmd>lua require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))<cr>',
-- 	{ desc = "DAP: Set Conditional Breakpoint" }
-- )
-- M(
-- 	"n",
-- 	"<leader>lp",
-- 	'<cmd>lua require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))<cr>',
-- 	{ desc = "DAP: Set Logpoint" }
-- )
-- M("n", "<leader>dr", '<cmd>lua require("dap").repl.open()<cr>', { desc = "DAP: Open REPL" })
-- M("n", "<leader>dl", '<cmd>lua require("dap").run_last()<cr>', { desc = "DAP: Run Last" })
-- M("n", "<leader>du", '<cmd>lua require("dapui").toggle()<cr>', { desc = "DAP: Toggle UI" })

M({ "n", "v" }, "<leader>ac", "<CMD>Augment chat<CR>", { desc = "Augment chat" })

M("n", "<leader>bd", ":bp<bar>sp<bar>bn<bar>bd<CR>")

-- Tabs
M("n", "<leader>tt", "<cmd>tabnew<cr>", { desc = "New tab" })
M("n", "<leader>tx", "<cmd>tabclose<cr>", { desc = "Close tab" })

M("n", "<leader>1", "1gt", { desc = "Go to tab 1" })
M("n", "<leader>2", "2gt", { desc = "Go to tab 2" })
M("n", "<leader>3", "3gt", { desc = "Go to tab 3" })
M("n", "<leader>4", "4gt", { desc = "Go to tab 4" })
M("n", "<leader>5", "5gt", { desc = "Go to tab 5" })
M("n", "<leader>6", "6gt", { desc = "Go to tab 6" })
M("n", "<leader>7", "7gt", { desc = "Go to tab 7" })
M("n", "<leader>8", "8gt", { desc = "Go to tab 8" })
M("n", "<leader>9", "9gt", { desc = "Go to tab 9" })
M("n", "<leader>0", "10gt", { desc = "Go to tab 10" })
M("n", "<leader>$", function()
	vim.ui.input({ prompt = "Enter Tab Name: " }, function(input)
		-- If the user provided input (didn't cancel), run the command
		if input then
			vim.cmd("LualineRenameTab " .. input)
		end
	end)
end, { desc = "Rename tab" })

M("n", "[t", ":tabprevious<CR>", { desc = "Previous tab" })
M("n", "]t", ":tabnext<CR>", { desc = "Next tab" })

local function term_move(key)
	vim.b.last_terminal_mode = "t"
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n><C-w>" .. key, true, true, true), "n", false)
end
-- escape from terminal mode
M("t", "<C-Space>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

M("t", "<C-h>", function() term_move("h") end, { desc = "Move left" })
M("t", "<C-j>", function() term_move("j") end, { desc = "Move down" })
M("t", "<C-k>", function() term_move("k") end, { desc = "Move up" })
M("t", "<C-l>", function() term_move("l") end, { desc = "Move right" })

-- keymaps for creating terminals similar to tmux splits, using Ctrl-b as prefix
M("n", "<C-Space>|", "<cmd>vsplit | terminal<cr>i", { desc = "Vertical terminal" })
M("n", "<C-Space>-", "<cmd>split | terminal<cr>i", { desc = "Horizontal terminal" })
M("n", "<C-Space>t", "<cmd>terminal<cr>i", { desc = "Open terminal" })
