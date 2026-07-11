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
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
          callArgumentNames = true,
        },
      },
    },
  },
})

-- inlay type hints on for python buffers
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("PyInlayHints", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method "textDocument/inlayHint" then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})

vim.api.nvim_create_user_command("ToggleInlayHints", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
end, { desc = "Toggle LSP inlay type hints" })

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
