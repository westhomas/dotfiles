return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      files = {
        -- Show hidden and ignored files in file search, but exclude .git, node_modules, poetry.lock
        fd_opts = "--color=never --type f --hidden --follow --no-ignore --exclude .git --exclude node_modules --exclude poetry.lock",
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --no-ignore --glob '!.git/' --glob '!node_modules/' --glob '!poetry.lock'",
      },
    },
  },
}
