-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Tab/Shift+Tab for indent/unindent in visual mode
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent and reselect" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent and reselect" })

-- Tab/Shift+Tab for indent/unindent in normal mode
vim.keymap.set("n", "<Tab>", ">>", { desc = "Indent line" })
vim.keymap.set("n", "<S-Tab>", "<<", { desc = "Unindent line" })

-- Shift+Tab to unindent in insert mode
vim.keymap.set("i", "<S-Tab>", "<C-d>", { desc = "Unindent" })

-- Delete key should delete forward character
vim.keymap.set("i", "<C-d>", "<Delete>", { desc = "Delete forward character" })
vim.keymap.set("n", "<C-d>", "x", { desc = "Delete forward character" })

-- Smart splits: pane navigation (overrides LazyVim's <C-hjkl> window nav defaults)
-- Runs here (VeryLazy) so it takes priority over LazyVim's defaults
local ss = require("smart-splits")
vim.keymap.set("n", "<C-h>", ss.move_cursor_left, { desc = "Move to left pane" })
vim.keymap.set("n", "<C-j>", ss.move_cursor_down, { desc = "Move to below pane" })
vim.keymap.set("n", "<C-k>", ss.move_cursor_up, { desc = "Move to above pane" })
vim.keymap.set("n", "<C-l>", ss.move_cursor_right, { desc = "Move to right pane" })
vim.keymap.set("n", "<A-h>", ss.resize_left, { desc = "Resize pane left" })
vim.keymap.set("n", "<A-j>", ss.resize_down, { desc = "Resize pane down" })
vim.keymap.set("n", "<A-k>", ss.resize_up, { desc = "Resize pane up" })
vim.keymap.set("n", "<A-l>", ss.resize_right, { desc = "Resize pane right" })
