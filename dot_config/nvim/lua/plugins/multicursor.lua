-- ~/.config/nvim/lua/plugins/multicursor.lua
return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local map = vim.keymap.set

    -- Add cursor above/below (Ctrl+Alt+Arrow, like VS Code)
    map({ "n", "x" }, "<C-M-up>", function() mc.lineAddCursor(-1) end, { desc = "Add cursor above" })
    map({ "n", "x" }, "<C-M-down>", function() mc.lineAddCursor(1) end, { desc = "Add cursor below" })

    -- Add/skip by matching word (like VS Code Ctrl+D)
    map({ "n", "x" }, "<C-n>", function() mc.matchAddCursor(1) end, { desc = "Add cursor at next match" })
    map({ "n", "x" }, "<C-p>", function() mc.matchAddCursor(-1) end, { desc = "Add cursor at prev match" })
    map({ "n", "x" }, "<leader>q", function() mc.matchSkipCursor(1) end, { desc = "Skip next match" })

    -- Select all matches
    map({ "n", "x" }, "<C-a>", function() mc.matchAllAddCursors() end, { desc = "Add cursors on all matches" })

    -- Visual selection: insert/append on each line (with live editing)
    map("x", "I", mc.insertVisual)
    map("x", "A", mc.appendVisual)

    -- Add/remove cursors with ctrl+click
    map("n", "<c-leftmouse>", mc.handleMouse)

    -- Disable/enable cursors
    map({ "n", "x" }, "<c-q>", mc.toggleCursor)

    -- Clear all cursors with Ctrl+c
    map({ "n", "x" }, "<C-c>", function()
      if mc.hasCursors() then
        mc.clearCursors()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, false, true), "n", false)
      end
    end, { desc = "Clear cursors" })

    -- Keymap layer: these mappings only activate when multiple cursors exist
    mc.addKeymapLayer(function(layerSet)
      -- Rotate through cursors
      layerSet({ "n", "x" }, "<left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<right>", mc.nextCursor)

      -- Delete current cursor
      layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

      -- Clear cursors with Escape
      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)

    -- Customize cursor highlights
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { reverse = true })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end,
}
