return {
  -- ── Core: LSP, formatting, linting ────────────────────────────────────
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    -- mypy diagnostics (was null-ls); ruff diagnostics come from its LSP
    "mfussenegger/nvim-lint",
    ft = { "python" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = { python = { "mypy" } }

      local mypy = lint.linters.mypy
      mypy.args = vim.list_extend({
        "--python-executable",
        function()
          local virtual = os.getenv "VIRTUAL_ENV"
            or os.getenv "CONDA_PREFIX"
            or "/usr"
          return virtual .. "/bin/python3"
        end,
      }, mypy.args or {})

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group = vim.api.nvim_create_augroup("NvimLint", { clear = true }),
        pattern = "*.py",
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    config = function(_, opts)
      require("mason").setup(opts)
      -- v2.5 dropped MasonInstallAll; recreate it from ensure_installed
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
      end, { desc = "Install all mason packages listed in ensure_installed" })
    end,
    opts = {
      ensure_installed = {
        "basedpyright",
        "bash-language-server",
        "clang-format",
        "clangd",
        "codelldb",
        "debugpy",
        "eslint-lsp",
        "json-lsp",
        "lua-language-server",
        "mypy",
        "prettierd",
        "ruff",
        "rust-analyzer",
        "stylua",
        "tailwindcss-language-server",
        "typescript-language-server",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
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
        "latex",
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

  -- ── NvChad plugin overrides ───────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      opts.mapping["<C-u>"] = cmp.mapping.scroll_docs(4)
      opts.mapping["<C-f>"] = nil
      return opts
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, require "configs.telescope")
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "│" },
        delete = { text = "⤷" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┋" },
      },
      on_attach = function(bufnr)
        local gitsigns = require "gitsigns"
        local function bmap(mode, lhs, rhs, desc, opts)
          opts = opts or {}
          opts.buffer = bufnr
          opts.desc = desc
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        bmap("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gitsigns.prev_hunk()
          end)
          return "<Ignore>"
        end, "Jump to prev hunk", { expr = true })

        bmap("n", "<leader>hN", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gitsigns.next_hunk()
          end)
          return "<Ignore>"
        end, "Jump to next hunk", { expr = true })

        bmap("n", "<leader>hn", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gitsigns.prev_hunk()
          end)
          return "<Ignore>"
        end, "Jump to prev hunk", { expr = true })

        bmap("n", "<leader>hr", gitsigns.reset_hunk, "Reset hunk")
        bmap("n", "<leader>td", gitsigns.toggle_deleted, "Toggle deleted")
        bmap("n", "<leader>hd", gitsigns.toggle_deleted, "Toggle deleted")
        bmap("n", "<leader>hs", gitsigns.stage_hunk, "Stage hunk")
        bmap("n", "<leader>ha", gitsigns.stage_buffer, "Stage buffer")
        bmap("n", "<leader>hb", gitsigns.blame_line, "Blame line")

        bmap("n", "<leader>hg", function()
          local user_input = vim.fn.input "Press Enter to run `git push`"
          print(user_input)
          if user_input == "" then
            vim.api.nvim_command "!git push"
          else
            print "Execution canceled"
          end
        end, "Git push")

        bmap("n", "<leader>hm", function()
          vim.api.nvim_command "git commit --amend --no-edit"
        end, "Amend commit (no edit)")

        bmap("n", "<leader>hc", function()
          local commit_message = vim.fn.input "Enter Commit Message > "
          if commit_message == "" then
            print "Commit cancelled"
            return
          end
          vim.api.nvim_command(
            "silent !git commit -m " .. vim.fn.shellescape(commit_message)
          )
          print "Commit Successful"
        end, "Git commit")
      end,
    },
  },

  -- ── Git ───────────────────────────────────────────────────────────────
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = {},
    keys = {
      { "<leader>hy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Copy git link" },
      { "<leader>ht", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
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

  -- ── Editing / UI ──────────────────────────────────────────────────────
  {
    -- Pin working files per project; jump instantly regardless of buffer order
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = (function()
      local function harpoon()
        return require "harpoon"
      end
      local keys = {
        {
          "<M-a>",
          function()
            harpoon():list():add()
            vim.notify("Harpooned " .. vim.fn.expand "%:t")
          end,
          desc = "Harpoon add file",
        },
        {
          "<M-e>",
          function()
            harpoon().ui:toggle_quick_menu(harpoon():list())
          end,
          desc = "Harpoon quick menu",
        },
        {
          "<M-n>",
          function()
            harpoon():list():next()
          end,
          desc = "Harpoon next",
        },
        {
          "<M-p>",
          function()
            harpoon():list():prev()
          end,
          desc = "Harpoon prev",
        },
      }
      for i = 1, 4 do
        table.insert(keys, {
          "<M-" .. i .. ">",
          function()
            harpoon():list():select(i)
          end,
          desc = "Harpoon file " .. i,
        })
      end
      return keys
    end)(),
    config = function()
      require("harpoon"):setup()
    end,
  },
  {
    -- Project-wide find & replace with live ripgrep preview
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>rr",
        "<cmd>GrugFar<cr>",
        desc = "Find & replace in project",
      },
      {
        "<leader>rr",
        function()
          require("grug-far").with_visual_selection()
        end,
        mode = "x",
        desc = "Find & replace selection",
      },
      {
        "<leader>rf",
        function()
          require("grug-far").open { prefills = { paths = vim.fn.expand "%" } }
        end,
        desc = "Find & replace in current file",
      },
    },
    opts = {},
  },
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
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
      return require "configs.toggleterm"
    end,
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {},
  },
  {
    "folke/twilight.nvim",
    cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
    opts = {},
  },

  -- ── Database ──────────────────────────────────────────────────────────
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
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },

  -- ── Debugging ─────────────────────────────────────────────────────────
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "mason-org/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {},
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
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

  -- ── Rust ──────────────────────────────────────────────────────────────
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        server = {
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

  -- ── Markdown / LaTeX ──────────────────────────────────────────────────
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
      latex = {
        enabled = true,
        position = "above",
      },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
          important = { raw = "[!]", rendered = " ", highlight = "DiagnosticWarn" },
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
        local function bmap(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, {
            buffer = bufnr,
            desc = desc,
            silent = true,
          })
        end

        bmap({ "n", "i" }, "<M-CR>", "<cmd>MDListItemBelow<cr>", "Markdown list item below")
        bmap("n", "<leader>mt", "<cmd>MDTaskToggle<cr>", "Markdown toggle task")
        bmap("x", "<leader>mt", ":MDTaskToggle<cr>", "Markdown toggle tasks")
        bmap("n", "<leader>mo", "<cmd>MDToc<cr>", "Markdown outline")
        bmap("n", "<leader>mn", "<cmd>MDInsertToc<cr>", "Markdown insert TOC")
        bmap("n", "<leader>mr", "<cmd>RenderMarkdown buf_toggle<cr>", "Markdown render toggle")
        bmap("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", "Markdown browser preview")
        bmap("n", "<leader>mi", "<cmd>PasteImage<cr>", "Markdown paste image")
        bmap("n", "<leader>mT", "<cmd>TableModeToggle<cr>", "Markdown table mode")
        bmap("n", "<leader>mz", "<cmd>ZenMode<cr>", "Markdown zen mode")
        bmap("n", "<leader>m$", "<cmd>MathDollar<cr>", "Markdown \\(..\\) math to $..$")
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
          path = [[/Users/joe/Library/Mobile Documents/iCloud~md~obsidian/Documents/DocsQuickSpec]],
        },
      },
      -- render-markdown.nvim owns in-buffer rendering; obsidian's overlapping
      -- checkbox/reference decorations fight it (checkhealth render-markdown)
      ui = { enable = false },
    },
  },

  -- ── Statusline / bufferline / notifications ───────────────────────────
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
          local icon = level:match "error" and " " or " "
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
