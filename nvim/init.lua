-- [[ Basic Editor Settings ]]
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set relativenumber")
vim.cmd("set number")
vim.g.mapleader = " "
vim.opt.autochdir = true

-- [[ Set up `lazy.nvim` package manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- [[ Plugin Specifications ]]
local plugins = {
    -- Theme
    { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {} },
    -- Fuzzy Finder
    { "nvim-telescope/telescope.nvim", tag = "0.1.8", dependencies = { "nvim-lua/plenary.nvim" }, config = function()
        require("telescope").setup({
            defaults = {
                -- This should make telescope respect your current directory
                cwd = vim.fn.getcwd(),
            },
        })
    end },
    -- Treesitter for syntax highlighting
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "javascript", "java", "typescript", "python", "bash", "sql", "c", "cpp",
                    "html", "css", "json", "jsonc", "dart", "go", "gomod", "gosum", "php", "scss", "svelte", "tsx"
                },
                highlight = { enable = true },
                indent = { enable = true }
            })
        end
    },
    -- Treesitter context viewer
    "nvim-treesitter/nvim-treesitter-context",

  -- ===================================================================
  -- LSP (Language Server Protocol) Section - WITH MASON
  -- ===================================================================

  -- Mason for managing LSP servers, DAPs, linters, and formatters
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup({
    ui = {
        icons = {
            package_installed = "󰄬",
            package_pending = "",
            package_uninstalled = ""
        }
    }
})
    end
  },

  -- Bridge between Mason and lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "ts_ls", "jdtls", "pyright", "bashls", "sqlls", "clangd",
          "html", "cssls", "jsonls", "dartls", "gopls", "intelephense", "svelte"
        },
        automatic_installation = true,
      })
    end
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()


      -- Common on_attach function for keymaps
      local on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
        -- vim.keymap.del("n", "K", { buffer = bufnr })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
      end

      -- List of servers
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } }
            }
          }
        },
        ts_ls = {},
        jdtls = {},
        pyright = {},
        bashls = {},
        sqlls = {},
        clangd = {},
        html = {},
        cssls = {},
        jsonls = {},
        dartls = {},
        gopls = {},
        intelephense = {},
        svelte = {},
      }

      -- Configure each server
      for server_name, server_opts in pairs(servers) do
        lspconfig[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = server_opts.settings or {},
        })
      end
    end
  },

    -- ===================================================================
    -- Autocompletion Section
    -- ===================================================================
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" }, { name = "luasnip" },
                    { name = "buffer" }, { name = "path" },
                })
            })
        end
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    "tpope/vim-fugitive",
}

local opts = {}
require("lazy").setup(plugins, opts)

-- Set the colorscheme after lazy.nvim has loaded the plugin
vim.cmd.colorscheme "tokyonight-night"

-- [[ Keymaps ]]
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<C-p>", function()
  builtin.find_files({ cwd = vim.fn.getcwd() })
end, {})

vim.keymap.set("n", "<leader>fg", function()
  builtin.live_grep({ cwd = vim.fn.getcwd() })
end, {})

vim.keymap.set("n", "<leader>tc", function() require("treesitter-context").toggle() end, { desc = "Toggle Treesitter Context" })
vim.keymap.set("v", "<Tab>", ">gv", { noremap = true, silent = true })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true })

-- [[ UI Customization for LSP ]]
vim.diagnostic.config({ float = { border = "rounded" } })
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

-- [[ Harpoon Setup ]]
local harpoon = require("harpoon")

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
vim.keymap.set("n", "<A-h>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<A-l>", function() harpoon:list():next() end)

-- Navigate to files by position (1-4)
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)

vim.keymap.set("n", "<leader>gs", vim.cmd.Git)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

