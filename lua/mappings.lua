local commands = require("commands")
local opts = { noremap = true, silent = true }

-- Window splitting with SPACE-v SPACE-s
vim.keymap.set('n', '<leader>v', '<C-w>v', opts)
vim.keymap.set('n', '<leader>s', '<C-w>s', opts)

-- Navigation
vim.keymap.set('n', '<leader>h', '<C-w>h', opts)
vim.keymap.set('n', '<leader>j', '<C-w>j', opts)
vim.keymap.set('n', '<leader>k', '<C-w>k', opts)
vim.keymap.set('n', '<leader>l', '<C-w>l', opts)
vim.keymap.set('n', '<leader>]', '<C-w>]', opts)
vim.keymap.set('n', '<leader>[', '<C-w>[', opts)

-- Turn off highlight with SPACE-n
vim.keymap.set('n', '<leader>n', ':nohl<CR>', opts)

-- Substitute with SPACE-r
vim.keymap.set('n', '<leader>r', [[:%s/\<<C-r><C-w>\>/]], opts)

-- Buffer switching mappings
for i = 1, 9 do
    vim.keymap.set('n', '<leader>'..i, ':b'..i..'<CR>', opts)
end

-- Save with SPACE-w
vim.keymap.set('n', '<leader>w', ':bd<CR>', opts)

-- Re-analyse syntax
vim.keymap.set('n', '<leader>m', ':syntax sync fromstart<CR>', opts)

-- Run Files
vim.keymap.set('n', '<D-r>', commands.compile_and_run, opts)
vim.keymap.set('n', '<C-r>', commands.compile_and_run, opts)
vim.keymap.set('n', '<F5>',  commands.compile_and_run, opts)

-- ensure move to next search makes cursor in the center and open folds
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- use SPACE + y to copy into clipboard
vim.keymap.set('n', '<leader>y', '\"+y', opts)
vim.keymap.set('v', '<leader>y', '\"+y', opts)
vim.keymap.set('n', '<leader>Y', '\"+Y', opts)

-- use SPACE + e/E to go to next/previous errors
vim.keymap.set('n', '<leader>e', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>E', vim.diagnostic.goto_prev, opts)
