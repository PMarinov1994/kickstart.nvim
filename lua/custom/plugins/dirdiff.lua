return {
  {
    -- We treat the local folder as a plugin
    -- ### start of dev config ###
    -- dir = vim.fn.stdpath("config") .. "/lua/dirdiff",
    -- dev = true
    -- ### end ###
    -- From Github
    "finegs/dirdiff.nvim",
    -- branch = "main",
    cmd = "DirDiff",
    lazy = true, -- Load immediately so the command is available
    opts = {
      hideSame = false,
    },
    config = function()
      -- Load the init.lua we just wrote
      require("dirdiff")
    end,
  },
}
