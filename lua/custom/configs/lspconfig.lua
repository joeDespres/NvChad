local base = require "plugins.configs.lspconfig"
local on_attach = base.on_attach
local capabilities = base.capabilities
local on_init = base.on_init

vim.lsp.config("clangd", {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,
  on_init = on_init,
  capabilities = capabilities,
})

local servers = {
  "eslint",
  "tailwindcss",
  "ts_ls",
}

for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
end

-- inline diagnostics (nvim 0.11 disables virtual text by default)
vim.diagnostic.config {
  virtual_text = { prefix = "●", severity = { min = vim.diagnostic.severity.HINT } },
  severity_sort = true,
}

-- basedpyright: pyright fork with inlay type hints
vim.lsp.config("basedpyright", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "python" },
  settings = {
    basedpyright = {
      disableOrganizeImports = true, -- ruff handles imports
      analysis = {
        typeCheckingMode = "standard",
        -- Don't typecheck the whole tree — only buffers you actually open.
        diagnosticMode = "openFilesOnly",
        -- Display only (via <leader>jt). Never written into the file.
        -- No call-arg names — those are the noisy foo(a=1) style inlays.
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = false,
        },
      },
    },
  },
})

-- Inlay type hints start OFF. Toggle display with <leader>jt (python) or
-- :ToggleInlayHints (any buffer). Showing only — nothing is written to the file.
vim.api.nvim_create_user_command("ToggleInlayHints", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local on = not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
  vim.lsp.inlay_hint.enable(on, { bufnr = bufnr })
  print("Inlay type hints " .. (on and "on" or "off"))
end, { desc = "Toggle LSP inlay type hints (display only)" })

-- ruff: lint diagnostics, code actions, import organization, formatting
vim.lsp.config("ruff", {
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false -- pyright owns hover
    on_attach(client, bufnr)
  end,
  on_init = on_init,
  capabilities = capabilities,
})

-- Enable all servers
vim.lsp.enable("clangd")
for _, lsp in ipairs(servers) do
  vim.lsp.enable(lsp)
end
vim.lsp.enable("basedpyright")
vim.lsp.enable("ruff")
