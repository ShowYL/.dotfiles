-- Set leader key before loading plugins
vim.g.mapleader = " "

-- Load core settings
require("core.options")
require("core.keymaps")

-- Load plugin manager and plugins
require("plugins")
