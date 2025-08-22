require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua", "javascript", "java", "typescript", "python", "bash", "sql", "c", "cpp",
    "html", "css", "json", "jsonc", "dart", "go", "gomod", "gosum", "php", "scss", "svelte", "tsx",
  },
  highlight = { enable = true },
  indent = { enable = true },
})

-- Treesitter context keymap
vim.keymap.set("n", "<leader>tc", function() require("treesitter-context").toggle() end, { desc = "Toggle Treesitter Context" })
