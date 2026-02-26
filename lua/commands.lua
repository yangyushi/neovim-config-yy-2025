local M = {}

local function q(s)
    return vim.fn.shellescape(s)
end

local function run_in_terminal(lines, cwd)
    local script_lines = {}
    if cwd and cwd ~= '' then
        table.insert(script_lines, 'cd ' .. q(cwd))
    end
    vim.list_extend(script_lines, lines)

    local script = table.concat(script_lines, '\n')
    local cmd = vim.o.shell .. ' -lc ' .. q(script)

    vim.cmd('botright 12split')
    vim.cmd('enew')
    vim.bo.bufhidden = 'wipe'
    vim.fn.termopen(cmd)
    vim.cmd('startinsert')
end

function M.compile_and_run()
    vim.cmd('w')
    local ft = vim.bo.filetype
    local src_name = vim.fn.expand('%:t')
    local src_stem = vim.fn.expand('%:t:r')
    local src_dir = vim.fn.expand('%:p:h')

    if ft == 'c' then
        local exe = vim.fn.exepath('gcc')
        if exe == '' then exe = 'gcc' end
        run_in_terminal({
            string.format('echo "Using [%s]"', exe),
            string.format('echo "gcc -g %s -lz -o %s"', src_name, src_stem),
            string.format('%s -g %s -lz -o %s', q(exe), q(src_name), q(src_stem)),
            string.format('echo "./%s"', src_stem),
            'echo',
            string.format('time ./%s', q(src_stem)),
        }, src_dir)
    elseif ft == 'cpp' then
        local exe = vim.fn.exepath('g++')
        if exe == '' then exe = 'g++' end
        run_in_terminal({
            string.format('echo "Using [%s]"', exe),
            string.format('echo "g++ -g -std=c++20 %s -lz -o %s"', src_name, src_stem),
            string.format('%s -g -std=c++20 %s -lz -o %s', q(exe), q(src_name), q(src_stem)),
            string.format('echo "./%s"', src_stem),
            'echo',
            string.format('time ./%s', q(src_stem)),
        }, src_dir)
    elseif ft == 'rust' then
        run_in_terminal({
            'echo "cargo run"',
            'echo',
            'time cargo run',
        })
    elseif ft == 'cuda' then
        local exe = vim.fn.exepath('nvcc')
        if exe == '' then exe = 'nvcc' end
        run_in_terminal({
            string.format('echo "Using [%s]"', exe),
            string.format('echo "nvcc %s -o %s"', src_name, src_stem),
            string.format('%s %s -o %s', q(exe), q(src_name), q(src_stem)),
            string.format('echo "./%s"', src_stem),
            'echo',
            string.format('time ./%s', q(src_stem)),
        }, src_dir)
    elseif ft == 'java' then
        run_in_terminal({
            string.format('echo "javac %s"', src_name),
            string.format('javac %s', q(src_name)),
            string.format('echo "java %s"', src_stem),
            'echo',
            string.format('time java %s', q(src_stem)),
        }, src_dir)
    elseif ft == 'sh' then
        run_in_terminal({
            string.format('echo "bash %s"', src_name),
            'echo',
            string.format('time bash %s', q(src_name)),
        }, src_dir)
    elseif ft == 'python' then
        local exe = vim.fn.exepath('python')
        if exe == '' then exe = 'python' end
        run_in_terminal({
            string.format('echo "Using [%s]"', exe),
            string.format('echo "python %s"', src_name),
            'echo',
            string.format('time %s %s', q(exe), q(src_name)),
        }, src_dir)
    elseif ft == 'dot' then
        run_in_terminal({
            string.format('echo "dot -Tsvg -O %s && google-chrome %s.svg"', src_name, src_stem),
            string.format('dot -Tsvg -O %s && google-chrome %s.svg', q(src_name), q(src_stem)),
        }, src_dir)
    elseif ft == 'r' then
        run_in_terminal({
            string.format('echo "Rscript %s"', src_name),
            'echo',
            string.format('Rscript %s', q(src_name)),
        }, src_dir)
    else
        vim.notify('Unsupported filetype for compile_and_run: ' .. ft, vim.log.levels.WARN)
    end
end

return M
