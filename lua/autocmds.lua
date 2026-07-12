require "nvchad.autocmds"

local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

-- ── External file changes ─────────────────────────────────────────────
local external_changes = augroup "ExternalChangesWin"

-- Even when the buffer has unsaved edits, discard them and use the disk version.
api.nvim_create_autocmd("FileChangedShell", {
  group = external_changes,
  pattern = "*",
  callback = function()
    if vim.v.fcs_reason ~= "deleted" then
      vim.v.fcs_choice = "reload"
    end
  end,
  desc = "Always accept externally changed files",
})

-- Fallback detection when returning to Neovim or changing buffers.
api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = external_changes,
  pattern = "*",
  command = "silent! checktime",
  desc = "Check whether files changed on disk",
})

api.nvim_create_autocmd({ "FocusLost" }, {
  command = "silent! wa",
})

-- ── Writing filetypes: wrap + spell ───────────────────────────────────
api.nvim_create_autocmd("FileType", {
  group = augroup "WrapSpell",
  pattern = { "text", "gitcommit", "markdown", "tex", "typst" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "↳  "
    vim.opt_local.colorcolumn = ""
    vim.opt_local.textwidth = 0
  end,
})

api.nvim_create_autocmd("FileType", {
  group = augroup "MarkdownWriting",
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
    vim.opt_local.cursorline = true
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt_local.foldlevel = 99
    vim.opt_local.formatoptions:append { "r", "o" }
  end,
})

-- ── Markdown math delimiters ──────────────────────────────────────────
-- Convert LaTeX-style \(...\) and \[...\] to markdown-standard $...$ and
-- $$...$$ so treesitter recognizes them and render-markdown can draw them.
api.nvim_create_user_command("MathDollar", function()
  local text = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local display, inline
  text, display = text:gsub("\\%[(.-)\\%]", "$$%1$$")
  text, inline = text:gsub("\\%(%s*(.-)%s*\\%)", "$%1$")
  if display + inline == 0 then
    vim.notify("No \\(..\\) or \\[..\\] math found", vim.log.levels.INFO)
    return
  end
  local cursor = api.nvim_win_get_cursor(0)
  api.nvim_buf_set_lines(0, 0, -1, false, vim.split(text, "\n"))
  pcall(api.nvim_win_set_cursor, 0, cursor)
  vim.notify(("Converted %d display + %d inline math delimiters"):format(display, inline))
end, { desc = "Convert \\(..\\)/\\[..\\] math to $..$/$$..$$" })

-- ── Markdown checkboxes ───────────────────────────────────────────────
-- Toggle: cycles between no checkbox -> [ ] -> [x] -> [ ]
local function toggle_markdown_checkbox()
  local line = api.nvim_get_current_line()
  local row = api.nvim_win_get_cursor(0)[1]
  local new_line
  local indent = line:match "^(%s*)" or ""

  if line:match "^(%s*)%- %[[xX]%]" then
    new_line = line:gsub("^(%s*)%- %[[xX]%]", "%1- [ ]")
  elseif line:match "^(%s*)%- %[ %]" then
    new_line = line:gsub("^(%s*)%- %[ %]", "%1- [x]")
  elseif line:match "^(%s*)%- " then
    new_line = line:gsub("^(%s*)%- ", "%1- [ ] ")
  else
    local content = line:gsub("^%s*", "")
    new_line = indent .. "- [ ] " .. content
  end

  api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
end

-- Auto-continue checkbox list on Enter
local function markdown_enter_handler()
  local line = api.nvim_get_current_line()
  local indent = line:match "^(%s*)" or ""

  if line:match "^%s*%- %[[xX ]%]" then
    local content_after = line:match "^%s*%- %[[xX ]%]%s*(.*)$" or ""

    if content_after:match "^%s*$" then
      -- Empty checkbox (just "- [ ]" with nothing after) - clear line and break out
      return "<C-u>"
    else
      -- Has content - continue with new unchecked checkbox
      return "<CR>" .. indent .. "- [ ] "
    end
  end

  return "<CR>"
end

-- Normal mode 'o' to continue checkbox list
local function markdown_o_handler()
  local line = api.nvim_get_current_line()
  local indent = line:match "^(%s*)" or ""

  if line:match "^%s*%- %[[xX ]%]" then
    return "o" .. indent .. "- [ ] "
  end

  return "o"
end

api.nvim_create_autocmd("FileType", {
  group = augroup "MarkdownCheckbox",
  pattern = { "markdown" },
  callback = function()
    vim.keymap.set({ "n", "i" }, "<C-CR>", toggle_markdown_checkbox, {
      buffer = true,
      desc = "Toggle markdown checkbox",
    })
    vim.keymap.set("i", "<CR>", markdown_enter_handler, {
      buffer = true,
      expr = true,
      desc = "Auto-continue markdown checkbox list",
    })
    vim.keymap.set("n", "o", markdown_o_handler, {
      buffer = true,
      expr = true,
      desc = "Auto-continue markdown checkbox list on o",
    })
  end,
})

-- ── Molten output highlights ──────────────────────────────────────────
local function set_molten_highlights()
  local highlights = {
    MoltenVirtualText = { fg = "#c7d1ff", bg = "#191828" },
    MoltenOutputWin = { fg = "#D9E0EE", bg = "#191828" },
    MoltenOutputWinNC = { fg = "#bfc6d4", bg = "#191828" },
    MoltenOutputBorder = { fg = "#89B4FA", bg = "#191828" },
    MoltenOutputBorderSuccess = { fg = "#ABE9B3", bg = "#191828" },
    MoltenOutputBorderFail = { fg = "#F38BA8", bg = "#191828" },
    MoltenOutputFooter = { fg = "#605f6f", bg = "#191828", italic = true },
  }
  for group, opts in pairs(highlights) do
    api.nvim_set_hl(0, group, opts)
  end
end

local molten_hl_group = augroup "MoltenHighlights"
api.nvim_create_autocmd("ColorScheme", {
  group = molten_hl_group,
  callback = set_molten_highlights,
})
api.nvim_create_autocmd("User", {
  group = molten_hl_group,
  pattern = "FilePost",
  callback = set_molten_highlights,
})
set_molten_highlights()

-- ── Window management ─────────────────────────────────────────────────
api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})

-- Quit when NvimTree is the last window left
local function is_modified_buffer_open(buffers)
  for _, v in pairs(buffers) do
    if v.name:match "NvimTree_" == nil then
      return true
    end
  end
  return false
end

api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if
      #api.nvim_list_wins() == 1
      and api.nvim_buf_get_name(0):match "NvimTree_" ~= nil
      and is_modified_buffer_open(vim.fn.getbufinfo { bufmodified = 1 })
        == false
    then
      vim.cmd "quit"
    end
  end,
})

-- ── LaTeX: compile + open PDF on save ─────────────────────────────────
api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  group = augroup "AutoCompileLatex",
  callback = function()
    local filename = vim.fn.expand "%:r"
    if vim.fn.executable "pdflatex" ~= 1 then
      vim.notify("pdflatex not found; skipping LaTeX compile", vim.log.levels.WARN)
      return
    end
    local cmd = string.format(
      "pdflatex %s 2>&1",
      vim.fn.shellescape(filename .. ".tex")
    )

    local output = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
      vim.api.nvim_err_writeln("LaTeX Compilation Failed:\n" .. output)
    else
      local open_cmd = vim.fn.has "mac" == 1 and "open"
        or vim.fn.has "unix" == 1 and "xdg-open"
        or "start"
      vim.fn.jobstart(
        { open_cmd, filename .. ".pdf" },
        { detach = true }
      )
    end
  end,
})

-- ── Formatting on save (json via jq, kdl via format_kdl) ──────────────
local format_group = augroup "AutoFormat"

api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.json",
  group = format_group,
  callback = function()
    if vim.fn.executable "jq" ~= 1 then
      return
    end
    local bufnr = api.nvim_get_current_buf()
    local view = vim.fn.winsaveview()
    local input = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
    local output = vim.fn.system("jq --indent 2 .", input)
    if vim.v.shell_error ~= 0 then
      vim.notify("jq failed; skipping JSON format", vim.log.levels.WARN)
      return
    end
    local lines = vim.split(output, "\n", { plain = true })
    if lines[#lines] == "" then
      table.remove(lines, #lines)
    end
    api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.fn.winrestview(view)
  end,
})

api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.kdl",
  group = format_group,
  callback = function()
    local bufname = vim.fn.expand "%"
    if vim.fn.fnamemodify(bufname, ":t") == "config.kdl" then
      return
    end
    if vim.fn.executable "format_kdl" ~= 1 then
      vim.api.nvim_echo({
        { "Note that `format_kdl` is a custom function", "WarningMsg" },
      }, true, {})
      return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local formatted_content =
      vim.fn.systemlist("format_kdl " .. vim.fn.shellescape(bufname))

    if vim.v.shell_error ~= 0 or #formatted_content == 0 then
      vim.api.nvim_echo({
        { "Formatting failed; check format_kdl output", "ErrorMsg" },
      }, true, {})
      return
    end
    if string.find(formatted_content[1], "^Error parsing KDL") ~= nil then
      vim.api.nvim_echo({
        {
          "Formatting failed with error: " .. formatted_content[1],
          "ErrorMsg",
        },
      }, true, {})
      return
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_content)
    vim.cmd "silent noautocmd write"
  end,
})

-- :W saves without formatting (skips all autocmds)
api.nvim_create_user_command("W", "noautocmd write", { desc = "Save without formatting" })

-- Notebook cells + kernel registration, LSP format-on-save
require "configs.notebook"
require "configs.format"
