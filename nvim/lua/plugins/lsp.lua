-- lua/plugins/lsp.lua

require("mason").setup({
  ui = {
    icons = {
      package_installed = "󰄬",
      package_pending = "",
      package_uninstalled = "",
    },
  },
})

-- Prepare lspconfig and capabilities for later use
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
end

require("mason-lspconfig").setup({
  -- A list of servers to automatically install if they're not already installed
  ensure_installed = {
    "gopls",
    "lua_ls",
    "jdtls",
    "pyright",
    "bashls",
    "sqlls",
    "clangd",
    "html",
    "cssls",
    "jsonls",
    "intelephense",
  },
  -- The 'handlers' key is the correct way to apply settings to each server.
  -- This function will be called for each server listed in 'ensure_installed'.
  handlers = {
    -- The default handler for servers that don't have a specific configuration
    function(server_name)
      lspconfig[server_name].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,

    -- You can also provide server-specific settings here, like this:
    ["gopls"] = function()
      lspconfig.gopls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          gopls = {
            -- Example of a gopls-specific setting
            -- staticcheck = true, 
          },
        },
      })
    end,
  },
})
