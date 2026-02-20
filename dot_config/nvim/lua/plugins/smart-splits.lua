return {
  {
    "mrjones2014/smart-splits.nvim",
    -- Must NOT be lazy loaded - plugin sets IS_NVIM user var on startup
    -- which WezTerm uses to detect nvim panes for smart navigation
    lazy = false,
    config = function()
      local ss = require("smart-splits")
      ss.setup({})

      -- Move between panes (Ctrl+hjkl) - nvim-aware, passes through to WezTerm when at edge
      vim.keymap.set("n", "<C-h>", ss.move_cursor_left, { desc = "Move to left pane" })
      vim.keymap.set("n", "<C-j>", ss.move_cursor_down, { desc = "Move to below pane" })
      vim.keymap.set("n", "<C-k>", ss.move_cursor_up, { desc = "Move to above pane" })
      vim.keymap.set("n", "<C-l>", ss.move_cursor_right, { desc = "Move to right pane" })

      -- Resize panes (Alt+hjkl)
      vim.keymap.set("n", "<A-h>", ss.resize_left, { desc = "Resize pane left" })
      vim.keymap.set("n", "<A-j>", ss.resize_down, { desc = "Resize pane down" })
      vim.keymap.set("n", "<A-k>", ss.resize_up, { desc = "Resize pane up" })
      vim.keymap.set("n", "<A-l>", ss.resize_right, { desc = "Resize pane right" })
    end,
  },
}
