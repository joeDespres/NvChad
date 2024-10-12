require "core.mappings"

local M = {}

vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_filetypes = {
  ["*"] = false, -- Disable Copilot globally
}

M.general = {
  i = {
    ["<M-BS>"] = { "<C-w>", "Delete word" },
  },
  n = {
    ["<C-u>"] = { "<C-u>zz", "center on control u" },
    ["<C-d>"] = { "<C-d>zz", "center on control d" },
    ["n"] = { "nzzzv", "keep search terms in the middle" },
    ["N"] = { "Nzzzv", "keep search terms in the middle" },
  },
  t = {},
}

M.copilot = {
  i = {
    ["<C-a>"] = {
      function()
        require("copilot.suggestion").accept()
      end,
      desc = "Accept Copilot suggestion",
    },
    ["<C-f>"] = {
      function()
        print "copilot"
        require("copilot.suggestion").accept_line()
      end,
      desc = "Accept Copilot word suggestion",
    },
    ["<C-j>"] = {
      function()
        require("copilot.suggestion").accept_word()
      end,
      desc = "Accept Copilot word suggestion",
    },
    ["<C-k>"] = {
      function()
        require("copilot.suggestion").next()
      end,
      desc = "Next Copilot suggestion",
    },
  },
}

M.dadbodui = {
  n = {
    ["<leader>a"] = { "<cmd> DBUIToggle <CR>" },
  },
}

M.gitlinker = {
  n = {
    ["<leader>hy"] = {
      function()
        require("gitlinker").get_buf_range_url(
          "n",
          { action_callback = require("gitlinker.actions").copy_to_clipboard }
        )
      end,
    },
    ["<leader>ht"] = {
      function()
        require("gitlinker").get_buf_range_url(
          "n",
          { action_callback = require("gitlinker.actions").open_in_browser }
        )
      end,
    },
  },
  v = {
    ["<leader>hy"] = {
      function()
        require("gitlinker").get_buf_range_url(
          "v",
          { action_callback = require("gitlinker.actions").copy_to_clipboard }
        )
      end,
    },
    ["<leader>ht"] = {
      function()
        require("gitlinker").get_buf_range_url(
          "v",
          { action_callback = require("gitlinker.actions").open_in_browser }
        )
      end,
    },
  },
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
  },
}

M.toggleterm = {
  n = {
    ["<C-\\>"] = {
      function()
        local buftype = vim.bo[0].buftype
        local filename = vim.fn.bufname "%"
        if buftype ~= "" and buftype ~= "acwrite" or filename == "" then
          print "Current buffer cannot be written."
        else
          vim.api.nvim_command ":w"
        end
        vim.api.nvim_command "ToggleTerm <CR>"
      end,
    },
    ["<C-]>"] = {
      function()
        local current_file_path = vim.fn.expand "%:p"
        vim.api.nvim_command ":w"
        local cmd
        if string.match(current_file_path, "%.cpp$") then
          cmd = "g++ " .. current_file_path .. " -o tmp_cpp && ./tmp_cpp"
          require("toggleterm").exec(cmd)
        elseif string.match(current_file_path, "%.rs$") then
          cmd = '[ -f "Cargo.lock" ] && cargo run'
          require("toggleterm").exec(cmd)
        elseif string.match(current_file_path, "%.py$") then
          cmd = "python " .. current_file_path
          require("toggleterm").exec(cmd)
        elseif string.match(current_file_path, "%.md$") then
          vim.api.nvim_command "MarkdownPreview"
        else
          print("echo not set up for file type" .. current_file_path)
        end
      end,
      "open terminal",
    },
  },
  i = {
    ["<C-\\>"] = {
      function()
        local buftype = vim.bo[0].buftype
        local filename = vim.fn.bufname "%"
        if buftype ~= "" and buftype ~= "acwrite" or filename == "" then
          print "Current buffer cannot be written."
        else
          vim.api.nvim_command ":w"
        end
        vim.api.nvim_command "ToggleTerm <CR>"
      end,
    },
  },
  t = {
    ["<C-\\>"] = {
      function()
        vim.api.nvim_command "ToggleTerm <CR>"
      end,
    },
  },
}

M.telescope = {
  plugin = true,
  i = {
    ["<M-BS>"] = { "<C-w>", "Delete word" },
  },
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

M.neogit = {
  n = {
    ["<leader>ho"] = {
      function()
        local neogit = require "neogit"
        neogit.open { kind = "split" }
      end,
    },
  },
}

M.gitsigns = {
  plugin = true,

  n = {
    -- Navigation through hunks
    ["<leader>hN"] = {
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
    ["<leader>hn"] = {
      function()
        if vim.wo.diff then
          return "]c"
        end
        vim.schedule(function()
          require("gitsigns").prev_hunk()
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
        local git_cmd = "git commit --amend --no-edit"
        vim.api.nvim_command(git_cmd)
      end,
      "git commit",
    },
    ["<leader>hc"] = {
      function()
        local commit_message = vim.fn.input "Enter Commit Message > "
        local git_cmd = 'silent !git commit -m "' .. commit_message .. '"'
        vim.api.nvim_command(git_cmd)
        print "Commit Successful"
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
    ["<C-x>"] = "",
    ["<A-h>"] = "",
  },
}
return M
