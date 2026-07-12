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

-- Resolve the kernel without prompting: use the buffer's attached kernel;
-- if none, attach this buffer to the single running kernel (molten's own
-- prompt path runs on a shared kernel WITHOUT attaching, so it re-prompts
-- on every evaluation). Returns nil when nothing is running yet.
local function ensure_kernel()
  local ok, attached = pcall(vim.fn.MoltenRunningKernels, true)
  if ok and #attached >= 1 then
    return attached[1]
  end
  local ok_all, running = pcall(vim.fn.MoltenRunningKernels, false)
  if ok_all and #running == 1 then
    vim.cmd("MoltenInit shared " .. running[1])
    return running[1]
  end
end

local function run_cell()
  local start, stop = cell_range()
  local kernel = ensure_kernel()
  local ok
  if kernel then
    ok = pcall(vim.fn.MoltenEvaluateRange, kernel, start, stop)
  else
    -- nothing running: let molten prompt for a kernel this one time
    ok = pcall(vim.fn.MoltenEvaluateRange, start, stop)
  end
  if not ok then
    vim.notify(
      "Molten kernel not running — start one with :MoltenInit (<leader>ji)",
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

    -- <leader>j = jupyter
    map("n", "<leader>ji", "<cmd>MoltenInit<cr>", "Jupyter init (pick kernel)")
    map("n", "<leader>je", run_cell, "Jupyter execute cell")
    map("n", "<leader>jn", run_cell_and_next, "Jupyter execute cell, goto next")
    map("n", "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", "Jupyter execute line")
    map("v", "<leader>je", ":<C-u>MoltenEvaluateVisual<cr>", "Jupyter execute selection")
    map("n", "<leader>jc", "<cmd>MoltenReevaluateCell<cr>", "Jupyter re-run molten cell")
    -- first press opens the output float (cursor stays in code);
    -- second press jumps into it; :q to come back
    map("n", "<leader>jo", "<cmd>noautocmd MoltenEnterOutput<cr>", "Jupyter show/enter output")
    map("n", "<leader>jh", "<cmd>MoltenHideOutput<cr>", "Jupyter hide output")
    map("n", "<leader>jd", "<cmd>MoltenDelete<cr>", "Jupyter delete cell output")
    map("n", "<leader>jp", "<cmd>MoltenImagePopup<cr>", "Jupyter open figure in Preview")
    map("n", "<leader>jx", "<cmd>MoltenInterrupt<cr>", "Jupyter interrupt kernel")
    map("n", "<leader>jR", "<cmd>MoltenRestart!<cr>", "Jupyter restart kernel")
    -- display-only inlay type hints (basedpyright); does not write into the file
    map("n", "<leader>jt", function()
      local bufnr = ev.buf
      local on = not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
      vim.lsp.inlay_hint.enable(on, { bufnr = bufnr })
      print("Inlay type hints " .. (on and "on" or "off"))
    end, "Toggle inlay type hints")
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

local kernel_setup = {}

local function prepare_kernel(venv, callback)
  local py = venv .. "/bin/python"
  local name = vim.fn.fnamemodify(venv:gsub("/%.?venv$", ""), ":t")

  local function do_register()
    vim.system(
      { py, "-m", "ipykernel", "install", "--user", "--name", name },
      { text = true },
      vim.schedule_wrap(function(out)
        if out.code == 0 then
          callback(name)
        else
          vim.notify("Kernel registration failed:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
        end
        kernel_setup[venv] = nil
      end)
    )
  end

  if kernel_setup[venv] then
    table.insert(kernel_setup[venv], callback)
    return
  end
  kernel_setup[venv] = { callback }

  local function finish(name)
    local callbacks = kernel_setup[venv] or {}
    for _, cb in ipairs(callbacks) do
      cb(name)
    end
  end
  callback = finish

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
                kernel_setup[venv] = nil
              end
            end))
        else
          vim.notify("ipykernel install failed:\n" .. (pip.stderr or ""), vim.log.levels.ERROR)
          kernel_setup[venv] = nil
        end
      end))
  end))
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
  prepare_kernel(venv, function(name)
    vim.notify("Kernel '" .. name .. "' registered")
  end)
end, { desc = "Register current venv as a Jupyter kernel (auto-installs ipykernel)" })

api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("NotebookAutoInit", { clear = true }),
  pattern = "python",
  callback = function(ev)
    vim.schedule(function()
      if not api.nvim_buf_is_valid(ev.buf) then
        return
      end
      local ok, attached = pcall(vim.fn.MoltenRunningKernels, true)
      if ok and #attached > 0 then
        return
      end
      local venv = find_venv()
      if not venv or vim.fn.executable(venv .. "/bin/python") ~= 1 then
        return
      end
      prepare_kernel(venv, function(name)
        if api.nvim_buf_is_valid(ev.buf) then
          api.nvim_buf_call(ev.buf, function()
            vim.cmd("MoltenInit " .. vim.fn.fnameescape(name))
          end)
          vim.notify("Molten initialized with kernel '" .. name .. "'")
        end
      end)
    end)
  end,
})
