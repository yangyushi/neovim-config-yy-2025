local M = {}

M.config = {
    terminal_height = 12,
    cpp_standard = 'c++20',
}

local function q(value)
    return vim.fn.shellescape(tostring(value))
end

---Convert argv into a shell-safe command string.
---@param argv string[]
---@return string
local function shell_command(argv)
    local result = {}

    for i, arg in ipairs(argv) do
        result[i] = q(arg)
    end

    return table.concat(result, ' ')
end

---Find an executable from a list of candidates.
---@param candidates string|string[]
---@return string?
local function find_executable(candidates)
    if type(candidates) == 'string' then
        candidates = { candidates }
    end

    for _, candidate in ipairs(candidates) do
        local path = vim.fn.exepath(candidate)

        if path ~= '' then
            return path
        end
    end

    vim.notify(
        'Executable not found: ' .. table.concat(candidates, ', '),
        vim.log.levels.ERROR
    )

    return nil
end

---Shell command that prints another command before running it.
---@param command string
---@return string
local function trace(command)
    return "printf '%s\\n' " .. q('$ ' .. command)
end

---Run shell statements in a terminal buffer.
---
---jobstart(..., { term = true }) is the replacement for deprecated termopen().
---@param lines string[]
---@param cwd string?
---@param on_exit fun(code: integer)|nil
---@return integer?
local function run_in_terminal(lines, cwd, on_exit)
    local script = table.concat(lines, '\n')

    -- Create an unmodified buffer, required by jobstart({ term = true }).
    vim.cmd(('botright %dnew'):format(M.config.terminal_height))

    local buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].bufhidden = 'wipe'

    -- Passing a string intentionally invokes 'shell'/'shellcmdflag'.
    -- This lets us use shell features such as && and time.
    local job = vim.fn.jobstart(script, {
        term = true,
        cwd = cwd,

        on_exit = function(_, code)
            if on_exit then
                vim.schedule(function()
                    on_exit(code)
                end)
            end
        end,
    })

    if job <= 0 then
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end

        vim.notify(
            ('Failed to start terminal job: %d'):format(job),
            vim.log.levels.ERROR
        )

        return nil
    end

    vim.cmd('startinsert')

    return job
end

---Build a script for a compile -> run workflow.
---@param build_argv string[]
---@param run_argv string[]
---@param exe string?
---@return string[]
local function compile_then_run(build_argv, run_argv, exe)
    local build = shell_command(build_argv)
    local run = shell_command(run_argv)

    local lines = {}

    if exe then
        lines[#lines + 1] =
            "printf '%s\\n' " .. q(('Using [%s]'):format(exe))
    end

    lines[#lines + 1] = trace(build)

    -- The executable is only run if compilation succeeds.
    lines[#lines + 1] = table.concat({
        build,
        trace(run),
        'echo',
        'time ' .. run,
    }, ' && ')

    return lines
end

---Build a script for an interpreted/single-command workflow.
---@param argv string[]
---@param exe string?
---@param timed boolean?
---@return string[]
local function run_command(argv, exe, timed)
    local command = shell_command(argv)
    local lines = {}

    if exe then
        lines[#lines + 1] =
            "printf '%s\\n' " .. q(('Using [%s]'):format(exe))
    end

    lines[#lines + 1] = trace(command)
    lines[#lines + 1] = 'echo'

    if timed then
        lines[#lines + 1] = 'time ' .. command
    else
        lines[#lines + 1] = command
    end

    return lines
end

function M.compile_and_run()
    local src = vim.api.nvim_buf_get_name(0)

    if src == '' then
        vim.notify(
            'Current buffer is not associated with a file',
            vim.log.levels.WARN
        )
        return
    end

    -- Only write if the buffer was actually modified.
    vim.cmd('update')

    local ft = vim.bo.filetype

    local src_name = vim.fs.basename(src)
    local src_dir = vim.fs.dirname(src)
    local src_stem = vim.fn.fnamemodify(src_name, ':r')

    -------------------------------------------------------------------------
    -- C
    -------------------------------------------------------------------------

    if ft == 'c' then
        local exe = find_executable({ 'gcc', 'clang', 'cc' })
        if not exe then
            return
        end

        run_in_terminal(
            compile_then_run(
                {
                    exe,
                    '-g',
                    src_name,
                    '-lz',
                    '-o',
                    src_stem,
                },
                {
                    './' .. src_stem,
                },
                exe
            ),
            src_dir
        )

    -------------------------------------------------------------------------
    -- C++
    -------------------------------------------------------------------------

    elseif ft == 'cpp' then
        local exe = find_executable({ 'g++', 'clang++', 'c++' })
        if not exe then
            return
        end

        run_in_terminal(
            compile_then_run(
                {
                    exe,
                    '-g',
                    '-std=' .. M.config.cpp_standard,
                    src_name,
                    '-lz',
                    '-o',
                    src_stem,
                },
                {
                    './' .. src_stem,
                },
                exe
            ),
            src_dir
        )

    -------------------------------------------------------------------------
    -- Rust / Cargo
    -------------------------------------------------------------------------

    elseif ft == 'rust' then
        local cargo = find_executable('cargo')
        if not cargo then
            return
        end

        -- Important: cargo must run at the Cargo.toml project root,
        -- not necessarily in the directory containing the current .rs file.
        local root = vim.fs.root(src, 'Cargo.toml')

        if not root then
            vim.notify(
                'Could not find Cargo.toml for current Rust file',
                vim.log.levels.ERROR
            )
            return
        end

        run_in_terminal(
            run_command(
                { cargo, 'run' },
                cargo,
                true
            ),
            root
        )

    -------------------------------------------------------------------------
    -- CUDA
    -------------------------------------------------------------------------

    elseif ft == 'cuda' then
        local exe = find_executable('nvcc')
        if not exe then
            return
        end

        run_in_terminal(
            compile_then_run(
                {
                    exe,
                    src_name,
                    '-o',
                    src_stem,
                },
                {
                    './' .. src_stem,
                },
                exe
            ),
            src_dir
        )

    -------------------------------------------------------------------------
    -- Java
    -------------------------------------------------------------------------

    elseif ft == 'java' then
        local javac = find_executable('javac')
        local java = find_executable('java')

        if not javac or not java then
            return
        end

        run_in_terminal(
            compile_then_run(
                {
                    javac,
                    src_name,
                },
                {
                    java,
                    src_stem,
                },
                javac
            ),
            src_dir
        )

    -------------------------------------------------------------------------
    -- Shell
    -------------------------------------------------------------------------

    elseif ft == 'sh' then
        local bash = find_executable('bash')
        if not bash then
            return
        end

        run_in_terminal(
            run_command(
                { bash, src_name },
                bash,
                true
            ),
            src_dir
        )

    -------------------------------------------------------------------------
    -- Python
    -------------------------------------------------------------------------

    elseif ft == 'python' then
        local python = find_executable({ 'python', 'python3' })
        if not python then
            return
        end

        run_in_terminal(
            run_command(
                { python, src_name },
                python,
                true
            ),
            src_dir
        )

    -------------------------------------------------------------------------
    -- Graphviz
    -------------------------------------------------------------------------

    elseif ft == 'dot' then
        local dot = find_executable('dot')
        if not dot then
            return
        end

        local output_name = src_stem .. '.svg'
        local output_path = vim.fs.joinpath(src_dir, output_name)

        local command = shell_command({
            dot,
            '-Tsvg',
            src_name,
            '-o',
            output_name,
        })

        run_in_terminal(
            {
                trace(command),
                command,
            },
            src_dir,
            function(code)
                if code ~= 0 then
                    return
                end

                -- Neovim 0.10+ API. Uses xdg-open/open/explorer etc.
                local _, err = vim.ui.open(output_path)

                if err then
                    vim.notify(
                        'Unable to open SVG: ' .. err,
                        vim.log.levels.WARN
                    )
                end
            end
        )

    -------------------------------------------------------------------------
    -- R
    -------------------------------------------------------------------------

    elseif ft == 'r' then
        local rscript = find_executable('Rscript')
        if not rscript then
            return
        end

        run_in_terminal(
            run_command(
                { rscript, src_name },
                rscript,
                true
            ),
            src_dir
        )

    -------------------------------------------------------------------------
    -- Unsupported
    -------------------------------------------------------------------------

    else
        vim.notify(
            'Unsupported filetype for compile_and_run: ' .. ft,
            vim.log.levels.WARN
        )
    end
end

return M
