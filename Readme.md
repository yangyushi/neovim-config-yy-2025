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

- neovim (tested on 0.10.4 and 0.11.0)
- [clangd](https://clangd.llvm.org/)
- [python-lsp](https://github.com/python-lsp/python-lsp-server)
- [lua-language-server](https://github.com/LuaLS/lua-language-server)

We need to ensure the following executables are available as [LSP servers](https://langserver.org/),

- clangd
- pylsp
- lua-language-server

## Fixing Broken Icons (Nerd Fonts)

Several plugins (file tree, status line, etc.) display icons that require a
[Nerd Font](https://www.nerdfonts.com/font-downloads) to be installed and
selected in your terminal emulator. Without one, you will see placeholder
boxes or question marks instead of icons.

Pick any font you like from **https://www.nerdfonts.com/font-downloads**, then
install it with the one-liner for your OS:

**macOS (Homebrew)**
```sh
brew install --cask font-jetbrains-mono-nerd-font
```

**Linux (official install script)**
```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ryanoasis/nerd-fonts/HEAD/install.sh)" -- JetBrainsMono
```

**Windows (winget)**
```powershell
winget install --id DEVCOM.JetBrainsMonoNerdFont
```

**Windows (Scoop)**
```powershell
scoop bucket add nerd-fonts; scoop install JetBrainsMono-NF
```

Replace `JetBrainsMono` / `JetBrainsMono-NF` with the name of whichever font
you prefer. After installation, set that font as the font in your terminal
emulator and restart Neovim.
