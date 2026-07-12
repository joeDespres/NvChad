-- Format-on-save via conform (with LSP fallback, e.g. ruff for python).
-- Loaded from autocmds.lua so it applies to every buffer from startup.

local enabled = true

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
  callback = function(ev)
    if not enabled then
      return
    end
    require("conform").format {
      bufnr = ev.buf,
      lsp_format = "fallback",
      timeout_ms = 2000,
    }
  end,
})

vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
  enabled = not enabled
  print("Format on save is now " .. (enabled and "enabled" or "disabled"))
end, {})
