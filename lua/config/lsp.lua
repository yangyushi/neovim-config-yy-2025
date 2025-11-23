local lspconfig = require('lspconfig')


lspconfig.clangd.setup{};
lspconfig.lua_ls.setup{};
lspconfig.rust_analyzer.setup{
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false;
      }
    }
  }
};
lspconfig.pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {enabled = false},
        pyflakes = {enabled = false},
        flake8 = {
            enabled = true,
            maxLineLength = 80,
            maxComplexity = 20,
        },
      }
    }
  }
};

