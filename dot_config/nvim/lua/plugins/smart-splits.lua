return {
  {
    "mrjones2014/smart-splits.nvim",
    -- Must NOT be lazy loaded - plugin sets IS_NVIM user var on startup
    -- which WezTerm uses to detect nvim panes for smart navigation
    lazy = false,
    config = function()
      local ss = require("smart-splits")
      ss.setup({ multiplexer_integration = "wezterm" })
    end,
  },
}
