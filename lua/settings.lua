vim.g.mapleader = ' '

-- Allow project specific vimrc file
vim.o.exrc = true
vim.o.secure = true

-- Formatting
vim.o.fileformat = 'unix'
vim.o.background = 'dark'
vim.o.signcolumn = 'yes'

-- Indentation
vim.o.autoindent = true
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99

-- Highlighting
vim.o.hlsearch = true
vim.o.showmatch = true
vim.o.incsearch = false

-- Clipboard
vim.g.clipboard = 'osc52'

-- Other settings
vim.o.autochdir = true
vim.o.ruler = false
vim.o.wrap = false

-- Encoding
vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'

-- LSP appearance
vim.diagnostic.config({ virtual_text = true })

-- New style for SHIFT-K pop up
vim.o.winborder = 'rounded'

-- Auto Completion
vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect", "popup" }
