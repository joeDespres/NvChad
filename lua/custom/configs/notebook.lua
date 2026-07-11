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

api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("NotebookCells", { clear = true }),
  pattern = "python",
  callback = function(ev)
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
    end

    map("n", "<leader>ri", "<cmd>MoltenInit<cr>", "Molten init (pick kernel)")
    map("n", "<leader>rr", run_cell, "Run current cell")
    map("n", "<leader>rn", run_cell_and_next, "Run cell, goto next")
    map("n", "<leader>rl", "<cmd>MoltenEvaluateLine<cr>", "Run line")
    map("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<cr>", "Run selection")
    map("n", "<leader>rc", "<cmd>MoltenReevaluateCell<cr>", "Re-run molten cell")
    map("n", "<leader>ro", "<cmd>noautocmd MoltenEnterOutput<cr>", "Show/enter output")
    map("n", "<leader>rh", "<cmd>MoltenHideOutput<cr>", "Hide output")
    map("n", "<leader>rd", "<cmd>MoltenDelete<cr>", "Delete cell output")
    map("n", "<leader>rp", "<cmd>MoltenImagePopup<cr>", "Open figure in Preview")
    map("n", "<leader>rx", "<cmd>MoltenInterrupt<cr>", "Interrupt kernel")
    map("n", "<leader>rR", "<cmd>MoltenRestart!<cr>", "Restart kernel")
    map("n", "]c", next_cell, "Next cell")
    map("n", "[c", prev_cell, "Prev cell")
  end,
})

-- Register the project venv as a Jupyter kernel so :MoltenInit can pick it.
-- Requires `ipykernel` in the project venv (`pip install ipykernel`).
api.nvim_create_user_command("PyKernelRegister", function()
  local venv = os.getenv "VIRTUAL_ENV"
  if not venv and vim.fn.isdirectory(vim.fn.getcwd() .. "/.venv") == 1 then
    venv = vim.fn.getcwd() .. "/.venv"
  end
  if not venv then
    vim.notify(
      "No venv found — activate one or select with <leader>rv",
      vim.log.levels.ERROR
    )
    return
  end
  local name = vim.fn.fnamemodify(venv:gsub("/%.?venv$", ""), ":t")
  vim.system(
    { venv .. "/bin/python", "-m", "ipykernel", "install", "--user", "--name", name },
    { text = true },
    vim.schedule_wrap(function(out)
      if out.code == 0 then
        vim.notify("Registered kernel '" .. name .. "' — :MoltenInit to use it")
      else
        vim.notify(
          "Kernel registration failed (is ipykernel installed in the venv?):\n"
            .. (out.stderr or ""),
          vim.log.levels.ERROR
        )
      end
    end)
  )
end, { desc = "Register current venv as a Jupyter kernel" })
