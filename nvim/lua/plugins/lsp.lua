-- Updated LSP configuration using vim.lsp.config (Neovim 0.11+)
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Common on_attach function for keymaps
local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
end

local servers = {
    'ts_ls',
    'jdtls',
    'pyright',
    'bashls',
    'sqlls',
    'clangd',
    'html',
    'cssls',
    'jsonls',
    'dartls',
    'gopls',
    'intelephense',
    'svelte',
}

vim.lsp.config('lua_ls', {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } }
        }
    }
})

for _, server in ipairs(servers) do
    if server ~= 'lua_ls' then  -- already configured above
        vim.lsp.config(server, {
            on_attach = on_attach,
            capabilities = capabilities,
        })
    end
    vim.lsp.enable(server)
end
