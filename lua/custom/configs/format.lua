-- Format-on-save, armed for any LSP client that can format (ruff for
-- python, null-ls for the rest). Loaded from custom/init.lua so it catches
-- clients that attach before lazily-loaded plugins finish setting up.

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local enabled = true

local function arm(bufnr)
  vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
  if not enabled then
    return
  end
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format { bufnr = bufnr }
    end,
  })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspFormattingAttach", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method "textDocument/formatting" then
      arm(ev.buf)
    end
  end,
})

vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
  enabled = not enabled
  print("Format on save is now " .. (enabled and "enabled" or "disabled"))
  arm(vim.api.nvim_get_current_buf())
end, {})
