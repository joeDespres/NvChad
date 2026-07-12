-- :W saves without formatting (bypasses autocommands)
vim.api.nvim_create_user_command("W", "noautocmd write", {})

local plugins = {
  {
    "williamboman/mason.nvim",
    opts = function()
      local opts = require "custom.configs.mason"
      return opts
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      local opts = require "plugins.configs.treesitter"
      opts.ensure_installed = {
        "bash",
        "c",
        "cpp",
        "css",
        "diff",
        "dockerfile",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "rust",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }
      -- auto-install a parser the first time a fenced code block uses a
      -- language not listed above, so markdown code blocks always highlight
      opts.auto_install = true
      return opts
    end,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      {
        "kristijanhusak/vim-dadbod-completion",
        ft = { "sql", "mysql", "plsql" },
        lazy = true,
      },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = {},
    keys = {
      { "<leader>hy", "<cmd>GitLink<cr>",  mode = { "n", "v" }, desc = "Copy git link" },
      { "<leader>ht", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "html",
      "javascript",
      "javascriptreact",
      "jsx",
      "markdown",
      "php",
      "svelte",
      "tsx",
      "typescript",
      "typescriptreact",
      "vue",
      "xml",
    },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    opts = function()
      return require "custom.configs.toggle-term"
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {},
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(client, bufnr)
            require("core.utils").load_mappings("lspconfig", { buffer = bufnr })
            if client.server_capabilities.signatureHelpProvider then
              require("nvchad.signature").setup(client)
            end
          end,
          default_settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        },
      }
    end,
  },
  -- ── Python / PyTorch / notebooks ──────────────────────────────────────
  {
    -- Run code cells against a live Jupyter kernel, output shown inline.
    "benlubas/molten-nvim",
    version = "^1",
    ft = { "python" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "none" -- alacritty: no inline images
      vim.g.molten_auto_image_popup = true -- figures auto-open in Preview
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true -- text output inline below cell
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_max_lines = 24
      vim.g.molten_output_win_max_height = 30
      vim.g.molten_output_win_max_width = 120
    end,
  },
  {
    -- Open/edit/save .ipynb transparently as percent-format python
    "GCBallesteros/jupytext.nvim",
    lazy = false, -- must catch BufReadCmd for *.ipynb
    opts = {
      style = "percent",
    },
  },
  {
    -- Pick/auto-detect project venvs; restarts pyright/ruff on switch
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    ft = "python",
    keys = {
      { "<leader>jv", "<cmd>VenvSelect<cr>", desc = "Select python venv" },
    },
    opts = {},
  },
  {
    -- Debug scripts and pytest with breakpoints via debugpy
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local debugpy = vim.fn.stdpath "data"
        .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(debugpy)
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_page_title = "${name}"
      vim.g.mkdp_theme = "dark"
    end,
  },
  {
    "lervag/vimtex",
    ft = { "tex", "latex", "markdown" },
    init = function()
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "open"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preset = "obsidian",
      completions = { lsp = { enabled = true } },
      heading = {
        width = "block",
        left_pad = 1,
        right_pad = 1,
      },
      code = {
        border = "thin",
        width = "block",
        left_pad = 1,
        right_pad = 1,
      },
      bullet = {
        icons = { "●", "○", "◆", "◇" },
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          important = { raw = "[!]", rendered = " ", highlight = "DiagnosticWarn" },
        },
      },
      sign = { enabled = false },
    },
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      on_attach = function(bufnr)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            desc = desc,
            silent = true,
          })
        end

        map({ "n", "i" }, "<M-CR>", "<cmd>MDListItemBelow<cr>", "Markdown list item below")
        map("n", "<leader>mt", "<cmd>MDTaskToggle<cr>", "Markdown toggle task")
        map("x", "<leader>mt", ":MDTaskToggle<cr>", "Markdown toggle tasks")
        map("n", "<leader>mo", "<cmd>MDToc<cr>", "Markdown outline")
        map("n", "<leader>mn", "<cmd>MDInsertToc<cr>", "Markdown insert TOC")
        map("n", "<leader>mr", "<cmd>RenderMarkdown buf_toggle<cr>", "Markdown render toggle")
        map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", "Markdown browser preview")
        map("n", "<leader>mi", "<cmd>PasteImage<cr>", "Markdown paste image")
        map("n", "<leader>mT", "<cmd>TableModeToggle<cr>", "Markdown table mode")
        map("n", "<leader>mz", "<cmd>ZenMode<cr>", "Markdown zen mode")
      end,
    },
  },
  {
    "HakonHarnes/img-clip.nvim",
    ft = { "markdown" },
    cmd = { "PasteImage", "ImgClipDebug", "ImgClipConfig" },
    opts = {
      default = {
        dir_path = "assets",
        relative_to_current_file = true,
        prompt_for_file_name = true,
        show_dir_path_in_prompt = true,
      },
      filetypes = {
        markdown = {
          template = "![$CURSOR]($FILE_PATH)",
          url_encode_path = true,
        },
      },
    },
  },
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    cmd = { "TableModeToggle", "TableModeEnable", "TableModeDisable", "Tableize" },
    init = function()
      vim.g.table_mode_disable_mappings = 1
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "|"
      vim.g.table_mode_header_fillchar = "-"
    end,
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    "folke/twilight.nvim",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "docs",
          path = [[/Users/joe/Library/Mobile Documents/iCloud~md~obsidian/Documents/DocsQuickSpec]]
        },
      },
    },
  },
  -- Catppuccin colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mason = true,
        noice = true,
        telescope = {
          enabled = true,
        },
      },
    },
  },
  -- Noice - modern UI for cmdline, messages, popupmenu
  {
    "rcarriga/nvim-notify",
    opts = {
      top_down = false, -- notifications appear from bottom
      stages = "fade", -- subtle fade animation
      timeout = 2000, -- disappear faster (2 seconds)
      background_colour = "#000000",
      render = "minimal", -- less intrusive style
      max_width = 50,
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
      views = {
        cmdline_popup = {
          relative = "cursor",
          anchor = "SW",
          position = { row = 3, col = 10 },
        },
        cmdline_popupmenu = {
          position = "auto",
        },
      },
    },
  },
  -- Lualine statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    opts = {
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
  -- Bufferline - fancy tabbar
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "BufReadPost",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        themable = true,
        numbers = function(opts)
          return string.format("%s", opts.raise(opts.ordinal))
        end,
        indicator = {
          icon = "▎",
          style = "icon",
        },
        buffer_close_icon = "󰅖",
        modified_icon = "●",
        close_icon = "",
        left_trunc_marker = "",
        right_trunc_marker = "",
        max_name_length = 18,
        max_prefix_length = 15,
        truncate_names = true,
        tab_size = 20,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        offsets = {
          {
            filetype = "NvimTree",
            text = " File Explorer",
            text_align = "center",
            separator = true,
            highlight = "Directory",
          },
        },
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
        show_duplicate_prefix = true,
        separator_style = "slant", -- "slant" | "slope" | "thick" | "thin" | { "▏", "▕" }
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
      },
    },
    config = function(_, opts)
      -- Safely load catppuccin highlights
      local ok, catppuccin_hl = pcall(function()
        return require("catppuccin.groups.integrations.bufferline").get()
      end)
      if ok then
        opts.highlights = catppuccin_hl
      end
      require("bufferline").setup(opts)
      -- Keymaps for buffer navigation
      vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
      vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
      vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin buffer" })
      vim.keymap.set("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Close unpinned" })
      vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })
      vim.keymap.set("n", "<leader>br", "<cmd>BufferLineCloseRight<cr>", { desc = "Close buffers to the right" })
      vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", { desc = "Close buffers to the left" })
      -- Jump to buffer by number
      for i = 1, 9 do
        vim.keymap.set("n", "<leader>" .. i, function()
          require("bufferline").go_to(i, true)
        end, { desc = "Go to buffer " .. i })
      end
    end,
  },
}
return plugins
