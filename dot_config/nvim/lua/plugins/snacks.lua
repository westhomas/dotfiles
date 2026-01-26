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
  config = function(_, opts)
    require("snacks").setup(opts)

    -- Open snacks explorer automatically when vim starts
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- Only open if no files were specified or opening a directory
        if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
          require("snacks").explorer()
        end
      end,
    })
  end,
}
