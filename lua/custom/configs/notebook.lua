-- Cell-based python/notebook workflow (Molten + `# %%` cell markers).
-- Works identically for .py scripts and .ipynb notebooks (via jupytext.nvim).
-- Loaded from custom/init.lua

local api = vim.api

-- Current cell = lines between the `# %%` marker at/above the cursor and the
-- next marker (or buffer edges when markers are missing).
local function cell_range()
  local start = vim.fn.search("^# %%", "bcnW")
  if start == 0 then
    start = 1
  end
  local stop = vim.fn.search("^# %%", "nW")
  if stop == 0 then
    stop = api.nvim_buf_line_count(0)
  else
    stop = stop - 1
  end
  return start, stop
end

local function next_cell()
  vim.fn.search("^# %%", "W")
end

local function prev_cell()
  vim.fn.search("^# %%", "bW")
end

local function run_cell()
  local start, stop = cell_range()
  local ok = pcall(vim.fn.MoltenEvaluateRange, start, stop)
  if not ok then
    vim.notify(
      "Molten kernel not running — start one with :MoltenInit (<leader>ri)",
      vim.log.levels.WARN
    )
  end
end

local function run_cell_and_next()
  run_cell()
  next_cell()
end

-- Materialize inlay type hints into real annotations. basedpyright attaches
-- LSP textEdits to its hints (what VS Code applies on double-click); this
-- requests the hints for a line range and applies those edits.
local function apply_type_hints(line1, line2)
  local bufnr = api.nvim_get_current_buf()
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = line1 - 1, character = 0 },
      ["end"] = { line = line2, character = 0 },
    },
  }
  vim.lsp.buf_request(bufnr, "textDocument/inlayHint", params, function(err, hints, ctx)
    if err or not hints then
      vim.notify("No inlay hints available", vim.log.levels.WARN)
      return
    end
    -- Each hint's textEdits are generated as if applied alone, so several
    -- hints needing the same import each carry their own copy of the import
    -- edit. Dedupe imports by statement text and skip ones already present.
    local existing = {}
    for _, l in ipairs(api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      existing[vim.trim(l)] = true
    end
    local seen = {}
    local edits = {}
    for _, hint in ipairs(hints) do
      -- kind 1 = Type (annotations), kind 2 = Parameter (keyword-arg names);
      -- both get materialized
      for _, edit in ipairs(hint.textEdits or {}) do
        local import_line = edit.newText:match "^%s*(from%s.-%simport%s[^\n]+)"
          or edit.newText:match "^%s*(import%s[^\n]+)"
        local key
        if import_line then
          key = "import:" .. vim.trim(import_line)
        else
          key = table.concat({
            edit.range.start.line,
            edit.range.start.character,
            edit.range["end"].line,
            edit.range["end"].character,
            edit.newText,
          }, ":")
        end
        if not seen[key] and not (import_line and existing[vim.trim(import_line)]) then
          seen[key] = true
          table.insert(edits, edit)
        end
      end
    end
    if #edits == 0 then
      vim.notify("No insertable type hints in range", vim.log.levels.WARN)
      return
    end
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    vim.lsp.util.apply_text_edits(edits, bufnr, client and client.offset_encoding or "utf-16")
    vim.notify("Inserted " .. #edits .. " type annotation(s)")
  end)
end

api.nvim_create_user_command("TypesToText", function(cmd)
  apply_type_hints(cmd.line1, cmd.line2)
end, {
  range = "%", -- defaults to whole file, accepts :'<,'>TypesToText
  desc = "Insert inlay type hints as real annotations",
})

api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("NotebookCells", { clear = true }),
  pattern = "python",
  callback = function(ev)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
    end

    -- <leader>j = jupyter
    map("n", "<leader>ji", "<cmd>MoltenInit<cr>", "Jupyter init (pick kernel)")
    map("n", "<leader>je", run_cell, "Jupyter execute cell")
    map("n", "<leader>jn", run_cell_and_next, "Jupyter execute cell, goto next")
    map("n", "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", "Jupyter execute line")
    map("v", "<leader>je", ":<C-u>MoltenEvaluateVisual<cr>", "Jupyter execute selection")
    map("n", "<leader>jc", "<cmd>MoltenReevaluateCell<cr>", "Jupyter re-run molten cell")
    map("n", "<leader>jo", "<cmd>noautocmd MoltenEnterOutput<cr>", "Jupyter open output")
    map("n", "<leader>jh", "<cmd>MoltenHideOutput<cr>", "Jupyter hide output")
    map("n", "<leader>jd", "<cmd>MoltenDelete<cr>", "Jupyter delete cell output")
    map("n", "<leader>jp", "<cmd>MoltenImagePopup<cr>", "Jupyter open figure in Preview")
    map("n", "<leader>jx", "<cmd>MoltenInterrupt<cr>", "Jupyter interrupt kernel")
    map("n", "<leader>jR", "<cmd>MoltenRestart!<cr>", "Jupyter restart kernel")
    map("n", "<leader>jt", function()
      local l = api.nvim_win_get_cursor(0)[1]
      apply_type_hints(l, l)
    end, "Insert type hint on line")
    map("v", "<leader>jt", ":TypesToText<cr>", "Insert type hints in selection")
    map("n", "]c", next_cell, "Next cell")
    map("n", "[c", prev_cell, "Prev cell")
  end,
})

-- Register the project venv as a Jupyter kernel so :MoltenInit can pick it
-- and cells execute with the project's packages (torch etc.). Installs
-- ipykernel into the venv automatically when missing.
local function find_venv()
  local venv = os.getenv "VIRTUAL_ENV"
  if venv then
    return venv
  end
  -- look for .venv from the current file's dir upward, then cwd
  local hit = vim.fs.find(".venv", {
    upward = true,
    type = "directory",
    path = vim.fn.expand "%:p:h",
  })[1]
  if hit then
    return hit
  end
  if vim.fn.isdirectory(vim.fn.getcwd() .. "/.venv") == 1 then
    return vim.fn.getcwd() .. "/.venv"
  end
end

api.nvim_create_user_command("PyKernelRegister", function()
  local venv = find_venv()
  if not venv then
    vim.notify(
      "No venv found — activate one, select with <leader>jv, or create .venv",
      vim.log.levels.ERROR
    )
    return
  end
  local py = venv .. "/bin/python"
  local name = vim.fn.fnamemodify(venv:gsub("/%.?venv$", ""), ":t")

  local function do_register()
    vim.system(
      { py, "-m", "ipykernel", "install", "--user", "--name", name },
      { text = true },
      vim.schedule_wrap(function(out)
        if out.code == 0 then
          vim.notify("Kernel '" .. name .. "' registered — <leader>ji and pick it")
        else
          vim.notify("Kernel registration failed:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
        end
      end)
    )
  end

  vim.system({ py, "-c", "import ipykernel" }, {}, vim.schedule_wrap(function(probe)
    if probe.code == 0 then
      do_register()
      return
    end
    vim.notify("Installing ipykernel into " .. venv .. " …")
    vim.system({ py, "-m", "pip", "install", "ipykernel" }, { text = true },
      vim.schedule_wrap(function(pip)
        if pip.code == 0 then
          do_register()
        elseif vim.fn.executable "uv" == 1 then
          -- uv-created venvs ship without pip
          vim.system({ "uv", "pip", "install", "--python", py, "ipykernel" }, { text = true },
            vim.schedule_wrap(function(uvp)
              if uvp.code == 0 then
                do_register()
              else
                vim.notify("ipykernel install failed:\n" .. (uvp.stderr or ""), vim.log.levels.ERROR)
              end
            end))
        else
          vim.notify("ipykernel install failed:\n" .. (pip.stderr or ""), vim.log.levels.ERROR)
        end
      end))
  end))
end, { desc = "Register current venv as a Jupyter kernel (auto-installs ipykernel)" })
