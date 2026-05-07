# My NeoVim Configuration

It's 2025 now and I finally decided to try something other than Vim.

## How to "install" it

```sh
mkdir -p $HOME/.config
git clone https://github.com/yangyushi/neovim-config-yy-2025.git $HOME/.config/nvim
```

- Clone the repository and move (or soft link) it to `$HOME/.config/nvim`.
- Use command `:Lazy` to inspect plugin status

## Dependencies

The following tools must be installed and available on `$PATH`:

| Tool | Purpose |
|---|---|
| [neovim](https://neovim.io/) ≥ 0.10 | editor (tested on 0.10.4 and 0.11.0) |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | fuzzy file/text search |
| [luarocks](https://luarocks.org/) | plugin rock support (lazy.nvim) |
| [clangd](https://clangd.llvm.org/) | LSP for C/C++ |
| [pylsp](https://github.com/python-lsp/python-lsp-server) | LSP for Python |
| [lua-language-server](https://github.com/LuaLS/lua-language-server) | LSP for Lua |
| [pynvim](https://github.com/neovim/pynvim) | Python provider for Neovim |
| [neovim npm package](https://www.npmjs.com/package/neovim) | Node.js provider for Neovim |

### Debian / Ubuntu

```sh
sudo apt install ripgrep luarocks clangd lua-language-server python3-pylsp python3-pynvim
npm install -g neovim
```

> **Note:** `lua-language-server` may not be available in older Debian/Ubuntu releases.
> If `apt` cannot find it, download a pre-built binary from the
> [releases page](https://github.com/LuaLS/lua-language-server/releases) and place it on `$PATH`.

### Arch Linux

```sh
sudo pacman -S ripgrep luarocks clang lua-language-server python-lsp-server python-pynvim
npm install -g neovim
```

(`clang` ships `clangd`; `python-lsp-server` provides the `pylsp` executable.)

### Fedora

```sh
sudo dnf install ripgrep luarocks clang-tools-extra lua-language-server python3-pylsp python3-pynvim
npm install -g neovim
```

> **Note:** `lua-language-server` may require enabling a COPR repository on older Fedora releases.
> Check [copr.fedorainfracloud.org](https://copr.fedorainfracloud.org/) or use the upstream binary.

### macOS (Homebrew)

```sh
brew install ripgrep luarocks llvm lua-language-server
pip3 install python-lsp-server pynvim
npm install -g neovim
```

Add LLVM's `bin` directory to `$PATH` so that `clangd` is found:

```sh
echo 'export PATH="$(brew --prefix llvm)/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Windows (Scoop)

```powershell
scoop install ripgrep luarocks llvm lua-language-server
pip install python-lsp-server pynvim
npm install -g neovim
```

`clangd` is bundled with `llvm`. If you use [Chocolatey](https://chocolatey.org/) instead:

```powershell
choco install ripgrep llvm lua-language-server
pip install python-lsp-server pynvim
npm install -g neovim
```

> **Note:** `luarocks` for Windows can be downloaded from the
> [luarocks.org](https://luarocks.org/releases/) releases page if it is not
> available through your package manager.
