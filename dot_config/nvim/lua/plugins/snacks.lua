return {
  "folke/snacks.nvim",
  opts = {
    notifier = { enabled = true },
    explorer = {
      preview = {
        enabled = true,
      },
    },
    picker = {
      sources = {
        explorer = {
          hidden = true,
        },
      },
    },
  },
}
