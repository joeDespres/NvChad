local opt = vim.opt

opt.scrolloff = 10
opt.colorcolumn = "80"
opt.tabstop = 4
opt.relativenumber = true
opt.wrap = false
opt.swapfile = false
opt.shell = "/bin/zsh"

-- This autocmd sets the wrap and spell options to true for filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "*.txt", "*.tex", "*.typ", "gitcommit", "markdown" },
  callback = function()
    opt.wrap = true
    opt.spell = true
    opt.columns = 100
    opt.linebreak = true
  end,
})

-- disable copilot in certain dirs
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = {
    "*", --tmp disable
    "*/GastrographPackage/*",
    "*/gastrographpackage/*",
    "*/eng-infra/*",
    "*/afs-projects/*",
    "*/local-dev/*",
    "*/work/boot.zsh",
    "*.txt",
    "*.tex",
    "*.typ",
    "gitcommit",
    "markdown",
  },
  command = "Copilot disable",
})

vim.api.nvim_create_autocmd({ "FocusLost" }, {
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

vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if
        #vim.api.nvim_list_wins() == 1
        and vim.api.nvim_buf_get_name(0):match "NvimTree_" ~= nil
        and is_modified_buffer_open(vim.fn.getbufinfo { bufmodified = 1 })
        == false
    then
      vim.cmd "quit"
    end
  end,
})

vim.api.nvim_create_augroup("AutoFormat", {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  group = vim.api.nvim_create_augroup("AutoCompileLatex", { clear = true }),
  callback = function()
    local filename = vim.fn.expand "%:r"
    local cmd = string.format("pdflatex %s.tex 2>&1", filename)

    local output = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
      vim.api.nvim_err_writeln("LaTeX Compilation Failed:\n" .. output)
    else
      vim.fn.jobstart(
        string.format("open %s.pdf &", filename),
        { detach = true }
      )
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.json",
  group = "AutoFormat",
  callback = function()
    vim.api.nvim_command "silent %!jq --indent 2 ."
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = [[^(?!config\.kdl$).+\.kdl$]],
  group = "AutoFormat",
  callback = function()
    if not vim.fn.executable "format_kdl" then
      vim.api.nvim_echo({
        { "Note that `format_kdl` is a custom function", "WarningMsg" },
      }, true, {})
      return
    end

    local bufname = vim.fn.expand "%"
    local bufnr = vim.api.nvim_get_current_buf()
    local formatted_content = vim.fn.systemlist("format_kdl " .. bufname)

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
  end,
})
