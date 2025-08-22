-- [[ Keymaps ]]

local keymap = vim.keymap.set

keymap("n", "<leader>pv", vim.cmd.Ex)

-- Indentation
keymap("v", "<Tab>", ">gv", { noremap = true, silent = true })
keymap("v", "<S-Tab>", "<gv", { noremap = true, silent = true })

-- Git
keymap("n", "<leader>gs", vim.cmd.Git)

-- Move selected lines
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor in middle
keymap("n", "<C-d>", "<C-d>zz")
keymap("n", "<C-u>", "<C-u>zz")

-- Keep search terms in middle
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")

-- System clipboard
keymap("n", "<leader>y", '"+y')
keymap("v", "<leader>y", '"+y')
keymap("n", "<leader>Y", '"+Y')
