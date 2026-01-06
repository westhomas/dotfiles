return {
  "folke/which-key.nvim",
  opts = {
    preset = "helix",
    win = {
      padding = { 1, 2 }, -- [top/bottom, right/left]
      border = "rounded", -- border style
      title = true,
      title_pos = "center",
    },
    layout = {
      width = { min = 20, max = 50 },
      height = { min = 4, max = 25 },
      spacing = 3, -- spacing between columns
    },
  },
}
