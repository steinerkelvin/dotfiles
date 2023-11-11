-- non-yank delete
vim.keymap.set('n', '<space>d', ' "_d', { noremap = true })

-- disable netrw (required by nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- nvim-tree config
require("nvim-tree").setup()

-- telescope keymaps
local tl_builtin = require('telescope.builtin')
vim.keymap.set('n', '<space>ff', tl_builtin.find_files, {})
vim.keymap.set('n', '<space>fg', tl_builtin.live_grep, {})
vim.keymap.set('n', '<space>fb', tl_builtin.buffers, {})
vim.keymap.set('n', '<space>fh', tl_builtin.help_tags, {})
vim.keymap.set('n', '<space>fd', tl_builtin.treesitter, {})

-- LSP config
local lspconfig = require('lspconfig')
lspconfig.pyright.setup {}
lspconfig.nil_ls.setup {}

-- copilot config
local copilot = require("copilot")
copilot.setup({})

-- which key config
local wk = require("which-key")
wk.register()

-- theme config
require("monokai-pro").setup()
