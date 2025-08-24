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

