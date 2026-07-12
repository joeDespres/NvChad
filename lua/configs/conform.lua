-- Formatters previously provided through null-ls. Format-on-save is driven
-- by configs/format.lua (ToggleFormatOnSave-aware), not conform's own
-- format_on_save option.
local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    sql = { "sleek" },
    javascript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescript = { "prettierd" },
    typescriptreact = { "prettierd" },
    vue = { "prettierd" },
    css = { "prettierd" },
    scss = { "prettierd" },
    less = { "prettierd" },
    html = { "prettierd" },
    yaml = { "prettierd" },
    markdown = { "prettierd" },
    graphql = { "prettierd" },
    -- json is formatted by the jq BufWritePre autocmd (autocmds.lua)
    -- python is formatted by the ruff LSP (configs/format.lua lsp fallback)
  },

  formatters = {
    sleek = {
      command = "sleek",
      stdin = true,
    },
  },
}

return options
