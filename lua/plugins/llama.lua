return {
    'ggml-org/llama.vim',
    opts = {
        auto_fim = true,
        show_info = 1,
        llama_enabled = false
    },
    keys = {
        {
            "<F3>",
            function() vim.fn["llama#toggle"]() end,
            mode = { "n", "i" },
            desc = "Toggle llama.vim",
        },
    },
}
