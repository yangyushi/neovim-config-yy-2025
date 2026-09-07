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

-- Relative line number
vim.o.number = true
vim.o.relativenumber = true

-- Clipboard
vim.opt.clipboard = 'unnamedplus'
if not vim.g.neovide and (vim.env.SSH_TTY or vim.env.SSH_CONNECTION)
then
    vim.g.clipboard = 'osc52'  -- use OSC52 when running remotely in a terminal.
end

-- On WSL, pin the clipboard provider. Otherwise Neovim autodetects it by
-- probing several missing tools, and each failed executable() check scans
-- the slow /mnt/c Windows PATH entries (~3.5s startup penalty).
if vim.fn.has('wsl') == 1 and vim.fn.executable('win32yank.exe') == 1 then
    vim.g.clipboard = 'win32yank'
end

-- Other settings
vim.o.autochdir = true
vim.o.ruler = false
vim.o.colorcolumn = ""
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

-- Setting Colourscheme
vim.cmd.colorscheme("habamax")

-- Conserve terminal transparency
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })

-- Make neovide (windoes app) transparent
if vim.g.neovide then
    vim.g.neovide_opacity = 0.7
    vim.g.neovide_cursor_animation_length = 0.05
end
