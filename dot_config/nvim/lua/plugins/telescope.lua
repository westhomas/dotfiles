return {

  -- change telescope config
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim", -- https://github.com/nvim-telescope/telescope-fzf-native.nvim
        build = "make -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && make --build build --config Release && make --install build --prefix build",
      },
      "nvim-telescope/telescope-live-grep-args.nvim", -- https://github.com/nvim-telescope/telescope-live-grep-args.nvim
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
      telescope.load_extension("live_grep_args")
    end,

    -- opts will be merged with the parent spec
    opts = {
      defaults = {
        file_ignore_patterns = { ".git/", "node_modules", "poetry.lock" },
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--hidden",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--trim",
        },
      },
      -- extensions = {
      --   fzf = {},
      --   live_grep_args = {
      --   },
      -- },
    },
    keys = {
      {
        "<leader>/",
        function()
          -- https://github.com/nvim-telescope/telescope-live-grep-args.nvim
          -- Uses ripgrep args (rg) for live_grep
          -- Command examples:
          -- -i "Data"  # case insensitive
          -- -g "!*.md" # ignore md files
          -- -w # whole word
          -- -e # regex
          -- see 'man rg' for more
          require("telescope").extensions.live_grep_args.live_grep_args() -- see arguments given in extensions config
        end,
        desc = "Live Grep (Args)",
      },
    },
  },
}
