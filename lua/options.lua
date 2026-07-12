require "nvchad.options"

local opt = vim.opt

opt.scrolloff = 10
opt.colorcolumn = "80"
opt.relativenumber = true
opt.wrap = false
opt.swapfile = false
opt.shell = "/bin/zsh"
-- Automatically reload files changed by external programs.
opt.autoread = true

-- nvchad.options disables all default providers; molten-nvim needs python3.
vim.g.loaded_python3_provider = nil

-- Dedicated python host for remote plugins (Molten). Kept separate from
-- project venvs so it never collides with them.
vim.g.python3_host_prog = vim.fn.expand "~/.venvs/neovim/bin/python"
-- Appended (not prepended) so project pythons keep PATH priority; only the
-- `jupytext` CLI needs to resolve from here.
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.expand "~/.venvs/neovim/bin"
