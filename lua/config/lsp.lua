vim.lsp.config.clangd = {
  cmd = { 'clangd', '--background-index' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt', 'Makefile', '.git' },
  filetypes = { 'c', 'cpp' },
}

vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
}

vim.lsp.config.rust_analyzer = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
  settings = {
      diagnostics = { enable = false },
  },
}

vim.lsp.config.pylsp = {
  cmd = { "pylsp" },
  filetypes = { 'python' , 'py' },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
  settings = {
      plugins = {
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        flake8 = {
          enabled = true,
          maxLineLength = 80,
          maxComplexity = 25,
        },
      },
  },
}

vim.lsp.enable({ "clangd", "lua_ls", "rust_analyzer", "pylsp" })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
