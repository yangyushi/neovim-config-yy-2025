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

-- Other settings
vim.o.autochdir = true
vim.o.ruler = true
vim.o.wrap = false

-- Encoding
vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'

-- Python
vim.g.python3_host_prog = vim.fn.expand('~/.local/bin/python3.12')

-- LSP appearance
vim.diagnostic.config({ virtual_text = true })
