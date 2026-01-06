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
