-- Overrides merged on top of NvChad's telescope defaults (plugins/init.lua)
return {
  defaults = {
    prompt_prefix = "> ",
    selection_caret = "  ",
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        prompt_position = "bottom",
        preview_width = 0.55,
      },
      width = 0.87,
      height = 0.80,
    },
    file_ignore_patterns = { "node_modules" },
    path_display = { "truncate" },
    mappings = {
      i = {
        ["<esc>"] = function(...)
          return require("telescope.actions").close(...)
        end,
      },
    },
  },
}
