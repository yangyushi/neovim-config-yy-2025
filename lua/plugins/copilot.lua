return {
  "github/copilot.vim",
  config = function()
    -- Function to toggle Copilot
    local function toggle_copilot()
      if vim.g.copilot_enabled then
        vim.cmd('Copilot disable')
        vim.fn.setqflist({}, 'a', { title = 'Copilot Status', items = {{ text = 'Copilot Disabled' }} })
        print('Copilot Disabled')
        vim.g.copilot_enabled = false
      else
        vim.cmd('Copilot enable')
        vim.fn.setqflist({}, 'a', { title = 'Copilot Status', items = {{ text = 'Copilot Enabled' }} })
        print('Copilot Enabled')
        vim.g.copilot_enabled = true
      end
    end

    -- Map F4 to the toggle function
    vim.keymap.set('n', '<F4>', toggle_copilot, { desc = 'Toggle GitHub Copilot' })
  end,
}

