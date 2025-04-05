local M = {}


local function start_lsp(config)
    local bufnr = vim.api.nvim_get_current_buf()
    for _, client in pairs(vim.lsp.get_clients({bufnr = bufnr})) do
        if client.name == config.name then
            return
        end
    end
    vim.lsp.start(config)
end


function M.setup()
    -- automatic start Lua LSP
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        callback = function()
            local config = {
                name = "lua_ls",
                cmd = { "lua-language-server" },
                filetypes = { "lua" },
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                    },
                },
            }
            start_lsp(config)
        end,
    })

    -- automatic start Python LSP
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
            local config = {
                name = "pyright",
                cmd = { "pyright-langserver", "--stdio" },
                filetypes = { "python" },
            }
            start_lsp(config)
        end,
    })

    -- automatic start C/C++ LSP
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp" },
        callback = function()
            local config = {
                name  = "clangd",
                cmd = { "clangd" },
                filetypes = { "c", "cpp" },
            }
            start_lsp(config)
        end,
    })
end

return M
