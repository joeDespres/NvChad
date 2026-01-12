local M = {}

M.general = {
  i = {
    ["<M-BS>"] = { "<C-w>", "Delete word" },
    -- Move line up/down in insert mode
    ["<A-j>"] = { "<Esc>:m .+1<CR>==gi", "Move line down" },
    ["<A-k>"] = { "<Esc>:m .-2<CR>==gi", "Move line up" },
  },
  n = {
    ["<leader>mr"] = { ":CellularAutomaton make_it_rain<CR>", "Make it Rain" },
    ["<leader>ml"] = { ":CellularAutomaton game_of_life<CR>", "Game of Life" },

    -- Move lines up/down
    ["<A-j>"] = { ":m .+1<CR>==" , "Move line down" },
    ["<A-k>"] = { ":m .-2<CR>==", "Move line up" },

    -- Duplicate line
    ["<leader>d"] = { "yyp", "Duplicate line" },

    -- Select all
    -- ["<C-a>"] = { "ggVG", "Select all" },

    -- Quick save
    ["<leader>w"] = { "<cmd>w<CR>", "Save" },

    -- Close buffer without closing window
    ["<leader>x"] = { "<cmd>bp|bd #<CR>", "Close buffer" },

    -- Split navigation with Ctrl
    ["<C-Up>"] = { "<cmd>resize +2<CR>", "Resize up" },
    ["<C-Down>"] = { "<cmd>resize -2<CR>", "Resize down" },
    ["<C-Left>"] = { "<cmd>vertical resize -2<CR>", "Resize left" },
    ["<C-Right>"] = { "<cmd>vertical resize +2<CR>", "Resize right" },

    -- Buffer/tab navigation
    ["<C-l>"] = {
      function()
        if not pcall(vim.cmd, "BufferLineCycleNext") then
          vim.cmd "bnext"
        end
      end,
      "Next buffer",
    },
    ["<C-h>"] = {
      function()
        if not pcall(vim.cmd, "BufferLineCyclePrev") then
          vim.cmd "bprevious"
        end
      end,
      "Prev buffer",
    },

    -- Zen mode
    ["<leader>z"] = { "<cmd>ZenMode<CR>", "Zen mode" },

    -- Quick find and replace word under cursor
    ["<leader>rw"] = { ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", "Replace word" },

    -- Keep cursor centered when scrolling
    ["J"] = { "mzJ`z", "Join lines (centered)" },

    -- Clear search highlight
    ["<Esc>"] = { "<cmd>noh<CR>", "Clear highlights" },

    -- Quick split
    ["<leader>sv"] = { "<cmd>vsplit<CR>", "Vertical split" },
    ["<leader>sh"] = { "<cmd>split<CR>", "Horizontal split" },
    -- Note: <C-u>, <C-d>, n, N centering mappings are in core/mappings.lua
    ["<leader>cl"] = {
      function()
        vim.cmd "normal! c"
        vim.cmd "normal! oconsole.log("
        vim.cmd 'normal! "0p'
        vim.cmd "normal! i)"
      end,
    },
    ["<leader>gg"] = {
      function()
        local function url_encode(str)
          if str then
            str = string.gsub(str, "\n", "\r\n")
            str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
              return string.format("%%%02X", string.byte(c))
            end)
            str = string.gsub(str, " ", "+")
          end
          return str
        end

        local line = vim.api.nvim_get_current_line()
        if line ~= "" then
          local query = url_encode(line)
          local url = "https://www.google.com/search?q=" .. query
          local open_cmd = vim.fn.has "mac" == 1 and "open"
            or vim.fn.has "unix" == 1 and "xdg-open"
            or "start"
          vim.fn.system { open_cmd, url }
        end
      end,
      "Google Search",
    },
  },
}


M.dadbodui = {
  n = {
    ["<leader>a"] = { "<cmd> DBUIToggle <CR>" },
  },
}

-- gitlinker mappings are defined in the plugin spec (custom/plugins.lua)

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
    ["<leader>tv"] = {
      "<cmd> ToggleTerm direction=vertical <CR>",
      "toggle vertical terminal",
    },
    ["<leader>th"] = {
      "<cmd> ToggleTerm direction=horizontal <CR>",
      "toggle horizontal terminal",
    },
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
        elseif string.match(current_file_path, "%.js$") then
          cmd = "node " .. current_file_path
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
        if commit_message == "" then
          print "Commit cancelled"
          return
        end
        local git_cmd = "silent !git commit -m " .. vim.fn.shellescape(commit_message)
        vim.api.nvim_command(git_cmd)
        print "Commit Successful"
      end,
      "git commit",
    },
    ["<leader>hb"] = {
      function()
        require("gitsigns").blame_line()
      end,
      "Blame line",
    },
  },
}

local say_job_id = nil

local function toggle_say(content)
  if vim.fn.has "mac" ~= 1 then
    print "Speech only available on macOS"
    return
  end
  if say_job_id then
    vim.fn.jobstop(say_job_id)
    say_job_id = nil
    print "Speech stopped"
  else
    say_job_id = vim.fn.jobstart({ "say", "-r", "240" }, {
      detach = true,
      on_exit = function()
        say_job_id = nil
      end,
      stdin = "pipe",
    })
    if say_job_id > 0 then
      vim.api.nvim_chan_send(say_job_id, content)
      vim.fn.chanclose(say_job_id, "stdin")
      print "Speaking..."
    else
      print "Error starting speech"
    end
  end
end

M.say = {
  n = {
    ["<leader>sa"] = {
      function()
        local content = table.concat(
          vim.api.nvim_buf_get_lines(0, 0, -1, false),
          "\n"
        )
        toggle_say(content)
      end,
      "Toggle say whole buffer",
    },
    ["<leader>ss"] = {
      function()
        local content = vim.api.nvim_get_current_line()
        toggle_say(content)
      end,
      "Toggle say current line",
    },
  },
  v = {
    ["<leader>ss"] = {
      function()
        vim.cmd 'noau normal! gv"vy'
        local content = vim.fn.getreg "v"
        toggle_say(content)
      end,
      "Toggle say selection",
    },
  },
}

M.visual = {
  v = {
    -- Move selected lines up/down
    ["<A-j>"] = { ":m '>+1<CR>gv=gv", "Move selection down" },
    ["<A-k>"] = { ":m '<-2<CR>gv=gv", "Move selection up" },

    -- Stay in visual mode after indenting
    ["<"] = { "<gv", "Indent left" },
    [">"] = { ">gv", "Indent right" },

    -- Paste without yanking replaced text
    ["p"] = { '"_dP', "Paste without yank" },
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
