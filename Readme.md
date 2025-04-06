# My NeoVim Configuration

It's 2025 now and I finally decided to try something other than Vim.

## How to use it

- Clone the repository and move (or soft link) it to `$HOME/.config/nvim`.
- Use command `:Lazy` to inspect plugin status

## Dependencies

- neovim (tested on 0.10.4 and 0.11.0)
- [clangd](https://clangd.llvm.org/)
- [pyright](https://github.com/microsoft/pyright)
- [python-lsp](https://github.com/python-lsp/python-lsp-server)
- [lua-language-server](https://github.com/LuaLS/lua-language-server)

We need to ensure the following executables are available as [LSP servers](https://langserver.org/),

- clangd
- pyright
- pylsp
- lua-language-server
