local M = {}

function M.compile_and_run()
    vim.cmd('w')
    local ft = vim.bo.filetype
    if ft == 'c' then
        local exe = vim.fn.exepath('gcc')
        vim.cmd("!echo Using [" .. exe  .. "]")
        vim.cmd("!gcc -g % -lz -o %<")
        vim.cmd("!time ./%<")
    elseif ft == 'cpp' then
        local exe = vim.fn.exepath('g++')
        vim.cmd("!echo Using [" .. exe  .. "]")
        vim.cmd("!g++ -g -std=c++20 % -lz -o %<")
        vim.cmd("!time ./%<")
    elseif ft == 'rust' then
        vim.cmd("!time cargo run")
    elseif ft == 'cuda' then
        local exe = vim.fn.exepath('nvcc')
        vim.cmd("!echo Using [" .. exe  .. "]")
        vim.cmd("!nvcc % -o %<")
        vim.cmd("!time ./%<")
    elseif ft == 'java' then
        vim.cmd("! javac %; time java %<")
    elseif ft == 'sh' then
        vim.cmd("!time bash %")
    elseif ft == 'python' then
        vim.cmd("!time python %")
    elseif ft == 'dot' then
        vim.cmd("!xdot %")
    elseif ft == 'r' then
        vim.cmd("!Rscript %")
    end
end

return M
