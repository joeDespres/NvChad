local opt = vim.opt
local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

opt.scrolloff = 10
opt.colorcolumn = "80"
opt.relativenumber = true
opt.wrap = false
opt.swapfile = false
opt.shell = "/bin/zsh"
vim.o.autoread = true

api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  group = augroup("CheckTime"),
  command = "checktime",
})

-- This autocmd sets the wrap and spell options to true for filetypes
api.nvim_create_autocmd("FileType", {
  group = augroup("WrapSpell"),
  pattern = { "text", "gitcommit", "markdown", "tex", "typst" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.linebreak = true
    vim.opt_local.colorcolumn = "100"
  end,
})

-- Markdown checkbox toggle: cycles between no checkbox -> [ ] -> [x] -> [ ]
local function toggle_markdown_checkbox()
  local line = api.nvim_get_current_line()
  local row = api.nvim_win_get_cursor(0)[1]
  local new_line
  local indent = line:match("^(%s*)") or ""

  if line:match("^(%s*)%- %[[xX]%]") then
    new_line = line:gsub("^(%s*)%- %[[xX]%]", "%1- [ ]")
  elseif line:match("^(%s*)%- %[ %]") then
    new_line = line:gsub("^(%s*)%- %[ %]", "%1- [x]")
  elseif line:match("^(%s*)%- ") then
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
  local indent = line:match("^(%s*)") or ""

  -- Check if line is a checkbox
  if line:match("^%s*%- %[[xX ]%]") then
    local content_after = line:match("^%s*%- %[[xX ]%]%s*(.*)$") or ""

    if content_after:match("^%s*$") then
      -- Empty checkbox (just "- [ ]" with nothing after) - clear line and break out
      return "<C-u>"
    else
      -- Has content - continue with new unchecked checkbox
      return "<CR>" .. indent .. "- [ ] "
    end
  end

  -- Empty line or no checkbox - normal Enter
  return "<CR>"
end

-- Normal mode 'o' to continue checkbox list
local function markdown_o_handler()
  local line = api.nvim_get_current_line()
  local indent = line:match("^(%s*)") or ""

  if line:match("^%s*%- %[[xX ]%]") then
    return "o" .. indent .. "- [ ] "
  end

  return "o"
end

api.nvim_create_autocmd("FileType", {
  group = augroup("MarkdownCheckbox"),
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


api.nvim_create_autocmd({ "FocusLost" }, {
  command = "silent! wa",
})

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

local format_group = augroup("AutoFormat")
local latex_group = augroup("AutoCompileLatex")

api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  group = latex_group,
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

-- :W command to save without formatting (skips all autocmds)
vim.api.nvim_create_user_command('W', 'noautocmd write', { desc = 'Save without formatting' })

