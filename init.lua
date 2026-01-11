if vim.loader then
  vim.loader.enable()
end

require "core"

local custom_init_path =
  vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.uv.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end

-- Load base46 cache (regenerate if missing)
local base46_cache = vim.g.base46_cache .. "defaults"
if vim.uv.fs_stat(base46_cache) then
  dofile(base46_cache)
else
  vim.schedule(function()
    require("base46").compile()
    dofile(base46_cache)
    vim.notify("Regenerated base46 cache", vim.log.levels.INFO)
  end)
end
vim.opt.rtp:prepend(lazypath)
require "plugins"
