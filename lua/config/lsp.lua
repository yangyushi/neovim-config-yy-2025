require('lspconfig').pyright.setup{}
require('lspconfig').clangd.setup{}
require('lspconfig').lua_ls.setup{}
require('lspconfig').pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          maxLineLength = 80
        }
      }
    }
  }
}
