-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "kj", "<esc>", {})

-- Copy text
vim.keymap.set("v", "<C-c>", '"+y', {})

vim.keymap.set("n", "<leader>tb", "<cmd>w<cr><cmd>!./cp.sh compile %<cr>") -- Builds
vim.keymap.set("n", "<leader>tr", "<cmd>silent !./cp.sh run<cr>") -- Runs
vim.keymap.set("n", "<leader>tf", function() -- Flush the file
  local input = vim.fn.input("Name: ")
  if input ~= "" then
    vim.cmd("!./cp.sh flush " .. input)
  end
end)

vim.keymap.set("n", "<C-p>", 'ggVG"+p') -- For replacing the whole file with clipboard content
vim.keymap.set("n", "<C-a>", 'mzggVG"+y`zzz') -- For copying the whole file

vim.keymap.set("n", "<leader>n", "<cmd>Telescope notify<cr>")
vim.keymap.set("v", "<C-/>", "gc")

vim.keymap.set("n", "<leader>gr", "<cmd>Telescope lsp_references<cr>")
vim.keymap.set("n", "J", "mzJ`z")
