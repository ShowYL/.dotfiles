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
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.telescope")
    end,
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("plugins.treesitter")
    end,
  },
  "nvim-treesitter/nvim-treesitter-context",

  -- LSP and Autocompletion
  { "neovim/nvim-lspconfig", config = function() require("plugins.lsp") end },
  "mason-org/mason.nvim",
  "mason-org/mason-lspconfig.nvim",
  { "hrsh7th/nvim-cmp", config = function() require("plugins.cmp") end },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  -- Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.harpoon")
    end,
  },

  -- Git Integration
  "tpope/vim-fugitive",
}

local opts = {}
require("lazy").setup(plugins, opts)

-- Set the colorscheme after lazy.nvim has loaded the plugin
vim.cmd.colorscheme "tokyonight-night"
