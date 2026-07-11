local null_ls = require "null-ls"
-- format-on-save lives in custom/configs/format.lua (LspAttach-based,
-- covers ruff and null-ls alike)

local opts = {
  sources = {
    null_ls.builtins.formatting.clang_format,
    -- null_ls.builtins.formatting.json_tool,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.sql_formatter.with { command = { "sleek" } },
    null_ls.builtins.formatting.stylua,
    -- python formatting handled by ruff LSP (see lspconfig.lua)
    null_ls.builtins.diagnostics.markdownlint_cli2,
    null_ls.builtins.diagnostics.mypy.with {
      extra_args = function()
        local virtual = os.getenv "VIRTUAL_ENV"
            or os.getenv "CONDA_PREFIX"
            or "/usr"
        return { "--python-executable", virtual .. "/bin/python3" }
      end,
    },
  },
}

return opts
