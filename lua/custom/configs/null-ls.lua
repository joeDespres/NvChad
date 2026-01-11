local null_ls = require "null-ls"
local format_on_save_enabled = true
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local function setup_format_on_save(bufnr)
  vim.api.nvim_clear_autocmds {
    group = augroup,
    buffer = bufnr,
  }
  if not format_on_save_enabled then
    return
  end
  local clients = vim.lsp.get_active_clients { bufnr = bufnr }
  for _, client in pairs(clients) do
    if client.supports_method "textDocument/formatting" then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr }
        end,
      })
      break
    end
  end
end

local opts = {
  sources = {
    null_ls.builtins.formatting.clang_format,
    -- null_ls.builtins.formatting.json_tool,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.sql_formatter.with { command = { "sleek" } },
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.black.with { filetypes = { "python" } },
    null_ls.builtins.diagnostics.mypy.with {
      extra_args = function()
        local virtual = os.getenv "VIRTUAL_ENV"
            or os.getenv "CONDA_PREFIX"
            or "/usr"
        return { "--python-executable", virtual .. "/bin/python3" }
      end,
    },
  },
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      setup_format_on_save(bufnr)
    end
  end,
}

vim.api.nvim_create_user_command("ToggleFormatOnSave", function()
  format_on_save_enabled = not format_on_save_enabled
  print(
    "Format on save is now "
    .. (format_on_save_enabled and "enabled" or "disabled")
  )

  local bufnr = vim.api.nvim_get_current_buf()
  setup_format_on_save(bufnr)
end, {})
return opts
