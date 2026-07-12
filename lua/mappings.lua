require "nvchad.mappings"

local map = vim.keymap.set
local del = vim.keymap.del

-- ── Remove NvChad defaults we don't want ──────────────────────────────
-- <leader>h / <leader>v spawn terminals; those prefixes are used for
-- git hunks (<leader>h*) and splits (<leader>s*) here.
for _, lhs in ipairs { "<leader>h", "<leader>v", "<A-h>" } do
  pcall(del, "n", lhs)
end
pcall(del, "i", "<C-j>") -- keep <C-j> free in insert mode

-- ── Helpers ───────────────────────────────────────────────────────────
local function current_file_context(line_start, line_end)
  line_start = tonumber(line_start) or vim.api.nvim_win_get_cursor(0)[1]
  line_end = tonumber(line_end) or line_start

  if line_start < 1 then
    line_start = vim.api.nvim_win_get_cursor(0)[1]
  end

  if line_end < 1 then
    line_end = line_start
  end

  local filename = vim.fn.expand "%:."
  if filename == "" then
    filename = "[No Name]"
  end

  local context
  if line_end and line_end ~= line_start then
    local first = math.min(line_start, line_end)
    local last = math.max(line_start, line_end)
    context = string.format("%s:%d-%d", filename, first, last)
  else
    context = string.format("%s:%d", filename, line_start)
  end

  vim.fn.setreg('"', context)
  vim.cmd("silent! call setreg('+', " .. vim.fn.string(context) .. ")")
  print("Copied " .. context)
end

local function current_visual_file_context()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local visual_line = vim.fn.line "v"
  current_file_context(visual_line, cursor_line)
end

-- ── Insert mode ───────────────────────────────────────────────────────
map("i", "<M-BS>", "<C-w>", { desc = "Delete word" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })

-- ── Normal mode ───────────────────────────────────────────────────────
-- Keep cursor centered when scrolling and searching
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
map("n", "J", "mzJ`z", { desc = "Join lines (centered)" })

-- Diagnostics navigation with rounded float
map("n", "[d", function()
  vim.diagnostic.jump { count = -1, float = { border = "rounded" } }
end, { desc = "Goto prev diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump { count = 1, float = { border = "rounded" } }
end, { desc = "Goto next diagnostic" })

-- Move lines up/down
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

map("n", "<leader>d", "yyp", { desc = "Duplicate line" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>x", "<cmd>bp|bd #<CR>", { desc = "Close buffer" })

-- Split management
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Resize up" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Resize down" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Resize left" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize right" })

-- Buffer navigation (bufferline with plain :bnext fallback)
local function cycle_buffer(bufferline_cmd, fallback)
  return function()
    if not pcall(vim.cmd, bufferline_cmd) then
      vim.cmd(fallback)
    end
  end
end
map("n", "<C-l>", cycle_buffer("BufferLineCycleNext", "bnext"), { desc = "Next buffer" })
map("n", "<C-h>", cycle_buffer("BufferLineCyclePrev", "bprevious"), { desc = "Prev buffer" })
map("n", "<Tab>", cycle_buffer("BufferLineCycleNext", "bnext"), { desc = "Next buffer" })
map("n", "<S-Tab>", cycle_buffer("BufferLineCyclePrev", "bprevious"), { desc = "Prev buffer" })

map("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Zen mode" })
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })

-- Quick find and replace word under cursor
map(
  "n",
  "<leader>rw",
  ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "Replace word" }
)

-- Jump to parent scope using treesitter
map("n", "<leader>cc", function()
  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  if node then
    local parent = node:parent()
    if parent then
      local start_row = parent:start()
      vim.api.nvim_win_set_cursor(0, { start_row + 1, 0 })
      vim.cmd [[normal! _]]
    end
  end
end, { desc = "Jump to parent scope" })

map("n", "<leader>hu", function()
  current_file_context(vim.api.nvim_win_get_cursor(0)[1])
end, { desc = "Copy file context" })

map("n", "<leader>cl", function()
  vim.cmd "normal! c"
  vim.cmd "normal! oconsole.log("
  vim.cmd 'normal! "0p'
  vim.cmd "normal! i)"
end, { desc = "Wrap in console.log" })

map("n", "<leader>gg", function()
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
end, { desc = "Google search current line" })

-- Fun
map("n", "<leader>mr", ":CellularAutomaton make_it_rain<CR>", { desc = "Make it Rain" })
map("n", "<leader>ml", ":CellularAutomaton game_of_life<CR>", { desc = "Game of Life" })

-- ── Visual mode ───────────────────────────────────────────────────────
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("v", "p", '"_dP', { desc = "Paste without yank" })
map("v", "<leader>hu", current_visual_file_context, { desc = "Copy file context" })

-- ── Telescope ─────────────────────────────────────────────────────────
map("n", "<leader><leader>", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })

-- ── Dadbod UI ─────────────────────────────────────────────────────────
map("n", "<leader>a", "<cmd>DBUIToggle<CR>", { desc = "Toggle DB UI" })

-- ── DAP ───────────────────────────────────────────────────────────────
map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Add breakpoint at line" })
map("n", "<leader>dr", "<cmd>DapContinue<CR>", { desc = "Start or continue the debugger" })

-- ── Neogit ────────────────────────────────────────────────────────────
map("n", "<leader>ho", function()
  require("neogit").open { kind = "split" }
end, { desc = "Open Neogit" })

-- ── Toggleterm ────────────────────────────────────────────────────────
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "Toggle vertical terminal" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Toggle horizontal terminal" })

local function save_and_toggle_term()
  local buftype = vim.bo[0].buftype
  local filename = vim.fn.bufname "%"
  if buftype ~= "" and buftype ~= "acwrite" or filename == "" then
    print "Current buffer cannot be written."
  else
    vim.api.nvim_command ":w"
  end
  vim.api.nvim_command "ToggleTerm"
end

map({ "n", "i" }, "<C-\\>", save_and_toggle_term, { desc = "Save and toggle terminal" })
map("t", "<C-\\>", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })

map("n", "<C-]>", function()
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
end, { desc = "Run current file in terminal" })

-- ── Markdown/LaTeX compile to PDF ─────────────────────────────────────
map("n", "<leader>p", function()
  local filepath = vim.fn.expand "%:p"
  local filedir = vim.fn.expand "%:p:h"
  local filetype = vim.bo.filetype
  local pdf_name = vim.fn.expand "%:t:r" .. ".pdf"

  if filetype == "markdown" then
    vim.cmd "write"
    local cmd = string.format(
      'pandoc "%s" -f markdown+tex_math_single_backslash -t pdf -o "%s" '
        .. '--pdf-engine=xelatex --standalone --resource-path="%s" '
        .. '-V geometry:margin=0.8in -V colorlinks=true -V monofont="Menlo"',
      filepath,
      filedir .. "/" .. pdf_name,
      filedir
    )
    local result = vim.fn.system(cmd)
    if vim.v.shell_error == 0 then
      vim.fn.system { "open", filedir .. "/" .. pdf_name }
      print("📄 PDF compiled: " .. pdf_name)
    else
      print("❌ Compilation failed: " .. result)
    end
  elseif filetype == "tex" or filetype == "latex" then
    vim.cmd "VimtexCompile"
    vim.schedule(function()
      vim.cmd "VimtexView"
    end)
    print "📄 LaTeX compiled and opened"
  else
    print "⚠️  Not a markdown or LaTeX file"
  end
end, { desc = "Compile to PDF and open" })

-- ── Speech (macOS say) ────────────────────────────────────────────────
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

map("n", "<leader>sa", function()
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  toggle_say(content)
end, { desc = "Toggle say whole buffer" })

map("n", "<leader>ss", function()
  toggle_say(vim.api.nvim_get_current_line())
end, { desc = "Toggle say current line" })

map("v", "<leader>ss", function()
  vim.cmd 'noau normal! gv"vy'
  toggle_say(vim.fn.getreg "v")
end, { desc = "Toggle say selection" })
