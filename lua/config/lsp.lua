require('lspconfig').clangd.setup{};
require('lspconfig').lua_ls.setup{};
require('lspconfig').rust_analyzer.setup{
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false;
      }
    }
  }
};
require('lspconfig').pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {enabled = true},
        pyflakes = {enabled = false},
        flake8 = {enabled = true},
      }
    }
  }
};
