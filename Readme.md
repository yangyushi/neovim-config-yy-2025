# My NeoVim Configuration

It's 2025 now and I finally decided to try something other than Vim.

## How to "install" it

```sh
mkdir -p $HOME/.config
git clone https://github.com/yangyushi/neovim-config-yy-2025.git $HOME/.config/nvim
```

- Clone the repository and move (or soft link) it to `$HOME/.config/nvim`.
- Use command `:Lazy` to inspect plugin status

## Optional Dependencies

The configuration works out of the box. The optional tools below unlock additional features — install only what you need.

| Tool | What it enables | Official site |
|---|---|---|
| [ripgrep](https://github.com/BurntSushi/ripgrep) | powers `:Telescope live_grep` and `:Telescope grep_string` (full-text search across files) | https://github.com/BurntSushi/ripgrep |
| [luarocks](https://luarocks.org/) | lets lazy.nvim install plugins distributed as Lua rocks; some plugins require it at startup | https://luarocks.org |
| [clangd](https://clangd.llvm.org/) | LSP for `.c` / `.cpp` — diagnostics, completion, go-to-definition, hover docs | https://clangd.llvm.org |
| [pylsp](https://github.com/python-lsp/python-lsp-server) | LSP for `.py` — flake8 diagnostics, completion, go-to-definition, hover docs | https://github.com/python-lsp/python-lsp-server |
| [lua-language-server](https://github.com/LuaLS/lua-language-server) | LSP for `.lua` — diagnostics, completion, go-to-definition, hover docs (including for this config itself) | https://github.com/LuaLS/lua-language-server |
| [rust-analyzer](https://rust-analyzer.github.io/) | LSP for `.rs` — diagnostics, completion, go-to-definition, hover docs | https://rust-analyzer.github.io |
| [pynvim](https://github.com/neovim/pynvim) | Python remote-plugin provider — required by plugins that call into Python | https://github.com/neovim/pynvim |
| [neovim (npm)](https://www.npmjs.com/package/neovim) | Node.js remote-plugin provider — required by plugins that call into Node.js | https://www.npmjs.com/package/neovim |

### Installing via package managers

#### Debian / Ubuntu

```sh
sudo apt install ripgrep luarocks clangd lua-language-server python3-pylsp python3-pynvim
npm install -g neovim
```

> **Note:** `lua-language-server` may not be available in older releases.
> If `apt` cannot find it, grab a pre-built binary from the
> [releases page](https://github.com/LuaLS/lua-language-server/releases) and place it on `$PATH`.

#### Arch Linux

```sh
sudo pacman -S ripgrep luarocks clang lua-language-server python-lsp-server python-pynvim
npm install -g neovim
```

(`clang` ships `clangd`; `python-lsp-server` provides the `pylsp` executable.)

#### Fedora

```sh
sudo dnf install ripgrep luarocks clang-tools-extra lua-language-server python3-pylsp python3-pynvim
npm install -g neovim
```

> **Note:** `lua-language-server` may require enabling a COPR repository on older releases.
> Check [copr.fedorainfracloud.org](https://copr.fedorainfracloud.org/) or use the upstream binary.

#### macOS (Homebrew)

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

#### Windows (Scoop)

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

## Fixing Broken Icons (Nerd Fonts)

Several plugins (file tree, status line, etc.) display icons that require a
[Nerd Font](https://www.nerdfonts.com/font-downloads) to be installed and
selected in your terminal emulator. Without one, you will see placeholder
boxes or question marks instead of icons.

Pick any font you like from **https://www.nerdfonts.com/font-downloads**, then
install it with the one-liner for your OS:

**macOS (Homebrew)**
```sh
brew install --cask font-fira-code-nerd-font
```

**Linux (official install script)**
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ryanoasis/nerd-fonts/HEAD/install.sh)" -- FiraCode
```

**Windows (winget)**
```powershell
winget install --id DEVCOM.FiraCodeNerdFont
```

**Windows (Scoop)**
```powershell
scoop bucket add nerd-fonts; scoop install FiraCode-NF
```

Replace `FiraCode` / `FiraCode-NF` with the name of whichever font
you prefer. After installation, set that font as the font in your terminal
emulator and restart Neovim.
