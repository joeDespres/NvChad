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
    "*/GastrographPackage/*",
    "*/gastrographpackage/*",
    "*/eng-infra/*",
    "*/afs-projects/*",
    "*/local-dev/*",
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
  pattern = "*.json",
  group = "AutoFormat",
  callback = function()
    vim.api.nvim_command "%!jq"
  end,
})
