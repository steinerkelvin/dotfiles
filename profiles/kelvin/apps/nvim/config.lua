vim.g.mapleader = ' '

-- OSC 52 clipboard, scoped to the "*" register only ("+" stays system clipboard)
local osc52 = require('vim.ui.clipboard.osc52')
vim.g.clipboard = {
  name = "OSC52-star-only",
  copy = { ["*"] = osc52.copy("*") },
  paste = { ["*"] = osc52.paste("*") },
}
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"*y', { noremap = true })

-- non-yank delete (Delete without affecting registers)
vim.keymap.set('n', '<space>d', '"_d', { noremap = true })
vim.keymap.set('v', '<space>d', '"_d', { noremap = true })

-- autoread: pick up files changed on disk (eg by p9 sync) without prompting
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  command = 'checktime',
})

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
vim.lsp.enable({'pyright', 'nil_ls'})

-- copilot config
local copilot = require("copilot")
copilot.setup({})

-- which key config
local wk = require("which-key")
wk.setup()

-- theme config
require("monokai-pro").setup()

-- leap.nvim config (modern alternative to EasyMotion)
vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap)')
vim.keymap.set('n',             'S',  '<Plug>(leap-from-window)')

-- nvim-surround config
require('nvim-surround').setup()
