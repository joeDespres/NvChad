require "core.mappings"

local M = {}

M.general = {
  i = {},
  n = {
    ["<C-u>"] = { "<C-u>zz", "center on control u" },
    ["<C-d>"] = { "<C-d>zz", "center on control d" },
    ["n"] = { "nzzzv", "keep search terms in the middle" },
    ["N"] = { "Nzzzv", "keep search terms in the middle" },
  },
  t = {},
}

M.tabufline = {
  plugin = true,

  n = {
    -- cycle through buffers
    ["<C-l>"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "Goto next buffer",
    },

    ["<C-h>"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "Goto prev buffer",
    },

    -- close buffer + hide terminal buffer
    ["<C-x>"] = {
      function()
        require("nvchad.tabufline").close_buffer()
      end,
      "Close buffer",
    },
  },
}
M.toggleterm = {
  n = {
    ["<C-\\>"] = { "<cmd> ToggleTerm <CR>", "toggle term" },
  },
  t = {
    ["<C-\\>"] = { "<cmd> ToggleTerm <CR>", "toggle term" },
  },
  i = {
    ["<C-\\>"] = { "<cmd> ToggleTerm <CR>", "toggle term" },
  },
}
M.telescope = {
  plugin = true,
  n = {
    ["<leader><leader>"] = { "<cmd> Telescope live_grep <CR>", "Live grep" },
  },
}

M.dap = {
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Start or continue the debugger",
    },
  },
}

M.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    ["<leader>hn"] = {
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").next_hunk()
        end)
        return "<Ignore>"
      end,
      "Jump to next hunk",
      opts = { expr = true },
    },
    ["<leader>hd"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "delete chunk",
    },
    ["<leader>hs"] = {
      function()
        require("gitsigns").stage_hunk()
      end,
      "stage buffer",
    },
    ["<leader>ha"] = {
      function()
        require("gitsigns").stage_buffer()
      end,
      "stage buffer",
    },
    ["<leader>hg"] = {
      function()
        local user_input = vim.fn.input "Press Enter to run `git push`"
        local git_cmd = "!git push" -- TODO remember an ssh key
        print(user_input)
        if user_input == "" then
          vim.api.nvim_command(git_cmd)
        else
          print "Execution canceled"
        end
      end,
      "push",
    },
    ["<leader>hm"] = {
      function()
        local git_cmd = "!git commit --amend --no-edit"
        vim.api.nvim_command(git_cmd)
      end,
      "git commit",
    },
    ["<leader>hc"] = {
      function()
        local commit_message = vim.fn.input "Commit message > "
        local git_cmd = '!git commit -m "' .. commit_message .. '"'
        vim.api.nvim_command(git_cmd)
      end,
      "git commit",
    },
    ["<leader>hb"] = {
      function()
        package.loaded.gitsigns.blame_line()
      end,
      "Blame line",
    },
  },
}

M.disabled = {
  n = {
    ["<leader>h"] = "",
  },
}
return M
