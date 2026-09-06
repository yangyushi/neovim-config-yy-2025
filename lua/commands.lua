local M = {}

local is_windows = vim.fn.has('win32') == 1

M.config = {
    terminal_height = 12,

    c_flags = {
        '-g',
    },

    cpp_flags = {
        '-g',
        '-std=c++20',
    },

    cuda_flags = {},

    -- Add '-lz' here if a project actually needs zlib.
    c_link_flags = {},
    cpp_link_flags = {},
    cuda_link_flags = {},
}

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------

---@param parts string[][]
---@return string[]
local function join_argv(parts)
    local result = {}

    for _, part in ipairs(parts) do
        vim.list_extend(result, part)
    end

    return result
end

---@param argv string[]
---@return string
local function display_command(argv)
    local result = {}

    for i, arg in ipairs(argv) do
        if arg:find('%s') then
            result[i] = string.format('%q', arg)
        else
            result[i] = arg
        end
    end

    return table.concat(result, ' ')
end

---@param candidates string|string[]
---@return string?
local function find_executable(candidates)
    if type(candidates) == 'string' then
        candidates = { candidates }
    end

    for _, candidate in ipairs(candidates) do
        local exe = vim.fn.exepath(candidate)

        if exe ~= '' then
            return exe
        end
    end

    vim.notify(
        'Executable not found: ' .. table.concat(candidates, ', '),
        vim.log.levels.ERROR,
        { title = 'Runner' }
    )

    return nil
end

-------------------------------------------------------------------------------
-- Output window
-------------------------------------------------------------------------------

---@param title string
---@param argv string[]
---@param stdout string?
---@param stderr string?
local function show_process_error(title, argv, stdout, stderr)
    vim.cmd(
        ('botright %dnew'):format(M.config.terminal_height)
    )

    local buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = 'log'

    local lines = {
        title,
        '',
        '$ ' .. display_command(argv),
        '',
    }

    local function append_output(text)
        if not text or text == '' then
            return
        end

        vim.list_extend(
            lines,
            vim.split(text, '\n', {
                plain = true,
                trimempty = true,
            })
        )
    end

    append_output(stdout)
    append_output(stderr)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].modifiable = false
end

-------------------------------------------------------------------------------
-- Terminal execution
-------------------------------------------------------------------------------

---Run argv directly in a terminal.
---
---No shell is involved, so paths and arguments work correctly on
---Windows, Linux, and macOS.
---
---@param argv string[]
---@param cwd string?
---@param on_exit fun(code: integer)|nil
---@return integer?
local function run_in_terminal(argv, cwd, on_exit)
    vim.cmd(
        ('botright %dnew'):format(M.config.terminal_height)
    )

    local buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false

    local job = vim.fn.jobstart(argv, {
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
        pcall(
            vim.api.nvim_buf_delete,
            buf,
            { force = true }
        )

        vim.notify(
            ('Unable to start process: %s'):format(
                display_command(argv)
            ),
            vim.log.levels.ERROR,
            { title = 'Runner' }
        )

        return nil
    end

    vim.cmd('startinsert')

    return job
end

-------------------------------------------------------------------------------
-- Non-interactive subprocess
-------------------------------------------------------------------------------

---@param argv string[]
---@param cwd string?
---@param on_success fun(result: vim.SystemCompleted)
local function run_system(argv, cwd, on_success)
    local ok, err = pcall(function()
        vim.system(
            argv,
            {
                cwd = cwd,
                text = true,
            },
            function(result)
                vim.schedule(function()
                    if result.code ~= 0 then
                        show_process_error(
                            ('Process failed (exit %d)'):format(
                                result.code
                            ),
                            argv,
                            result.stdout,
                            result.stderr
                        )

                        return
                    end

                    on_success(result)
                end)
            end
        )
    end)

    if not ok then
        vim.notify(
            tostring(err),
            vim.log.levels.ERROR,
            { title = 'Runner' }
        )
    end
end

-------------------------------------------------------------------------------
-- Compile + run
-------------------------------------------------------------------------------

---@param build_argv string[]
---@param run_argv string[]
---@param cwd string
local function build_and_run(build_argv, run_argv, cwd)
    run_system(build_argv, cwd, function()
        run_in_terminal(run_argv, cwd)
    end)
end

-------------------------------------------------------------------------------
-- Java helpers
-------------------------------------------------------------------------------

---@param src_dir string
---@param src_stem string
---@return string class_name
---@return string classpath
local function java_class_info(src_dir, src_stem)
    local package

    local line_count = math.min(
        vim.api.nvim_buf_line_count(0),
        100
    )

    local lines = vim.api.nvim_buf_get_lines(
        0,
        0,
        line_count,
        false
    )

    for _, line in ipairs(lines) do
        package = line:match(
            '^%s*package%s+([%w_%.]+)%s*;'
        )

        if package then
            break
        end
    end

    if not package then
        return src_stem, src_dir
    end

    local classpath = src_dir

    for _ in package:gmatch('[^.]+') do
        local parent = vim.fs.dirname(classpath)

        if not parent then
            break
        end

        classpath = parent
    end

    return package .. '.' .. src_stem, classpath
end

-------------------------------------------------------------------------------
-- Main runner
-------------------------------------------------------------------------------

function M.compile_and_run()
    local buf = vim.api.nvim_get_current_buf()
    local src = vim.api.nvim_buf_get_name(buf)

    if src == '' then
        vim.notify(
            'Current buffer is not associated with a file',
            vim.log.levels.WARN,
            { title = 'Runner' }
        )

        return
    end

    ---------------------------------------------------------------------------
    -- Save first
    ---------------------------------------------------------------------------

    local saved, save_err = pcall(
        vim.cmd,
        'update'
    )

    if not saved then
        vim.notify(
            tostring(save_err),
            vim.log.levels.ERROR,
            { title = 'Runner' }
        )

        return
    end

    ---------------------------------------------------------------------------
    -- File information
    ---------------------------------------------------------------------------

    src = vim.fs.normalize(src)

    local ft = vim.bo[buf].filetype
    local src_dir = vim.fs.dirname(src)
    local src_name = vim.fs.basename(src)
    local src_stem = vim.fn.fnamemodify(src_name, ':r')

    if not src_dir then
        vim.notify(
            'Unable to determine source directory',
            vim.log.levels.ERROR,
            { title = 'Runner' }
        )

        return
    end

    ---------------------------------------------------------------------------
    -- C
    ---------------------------------------------------------------------------

    if ft == 'c' then
        local cc = find_executable({
            'gcc',
            'clang',
            'cc',
        })

        if not cc then
            return
        end

        local output = vim.fs.joinpath(
            src_dir,
            src_stem .. (is_windows and '.exe' or '')
        )

        local build_argv = join_argv({
            { cc },
            M.config.c_flags,
            {
                src,
                '-o',
                output,
            },
            M.config.c_link_flags,
        })

        build_and_run(
            build_argv,
            { output },
            src_dir
        )

        return
    end

    ---------------------------------------------------------------------------
    -- C++
    ---------------------------------------------------------------------------

    if ft == 'cpp' then
        local cxx = find_executable({
            'g++',
            'clang++',
            'c++',
        })

        if not cxx then
            return
        end

        local output = vim.fs.joinpath(
            src_dir,
            src_stem .. (is_windows and '.exe' or '')
        )

        local build_argv = join_argv({
            { cxx },
            M.config.cpp_flags,
            {
                src,
                '-o',
                output,
            },
            M.config.cpp_link_flags,
        })

        build_and_run(
            build_argv,
            { output },
            src_dir
        )

        return
    end

    ---------------------------------------------------------------------------
    -- Python
    ---------------------------------------------------------------------------

    if ft == 'python' then
        local candidates

        if is_windows then
            candidates = {
                'python',
                'python3',
                'py',
            }
        else
            candidates = {
                'python3',
                'python',
            }
        end

        local python = find_executable(candidates)

        if not python then
            return
        end

        run_in_terminal(
            {
                python,
                src,
            },
            src_dir
        )

        return
    end

    ---------------------------------------------------------------------------
    -- Rust
    ---------------------------------------------------------------------------

    if ft == 'rust' then
        local cargo = find_executable('cargo')

        if not cargo then
            return
        end

        local root = vim.fs.root(
            src,
            'Cargo.toml'
        )

        if not root then
            vim.notify(
                'Cargo.toml not found',
                vim.log.levels.ERROR,
                { title = 'Runner' }
            )

            return
        end

        -- Cargo performs both compilation and execution, so keeping it
        -- directly inside the terminal gives you all compiler/program output.
        run_in_terminal(
            {
                cargo,
                'run',
            },
            root
        )

        return
    end

    ---------------------------------------------------------------------------
    -- CUDA
    ---------------------------------------------------------------------------

    if ft == 'cuda' then
        local nvcc = find_executable('nvcc')

        if not nvcc then
            return
        end

        local output = vim.fs.joinpath(
            src_dir,
            src_stem .. (is_windows and '.exe' or '')
        )

        local build_argv = join_argv({
            { nvcc },
            M.config.cuda_flags,
            {
                src,
                '-o',
                output,
            },
            M.config.cuda_link_flags,
        })

        build_and_run(
            build_argv,
            { output },
            src_dir
        )

        return
    end

    ---------------------------------------------------------------------------
    -- Java
    ---------------------------------------------------------------------------

    if ft == 'java' then
        local javac = find_executable('javac')
        local java = find_executable('java')

        if not javac or not java then
            return
        end

        local class_name, classpath =
            java_class_info(src_dir, src_stem)

        run_system(
            {
                javac,
                src,
            },
            src_dir,
            function()
                run_in_terminal(
                    {
                        java,
                        '-cp',
                        classpath,
                        class_name,
                    },
                    classpath
                )
            end
        )

        return
    end

    ---------------------------------------------------------------------------
    -- Shell
    ---------------------------------------------------------------------------

    if ft == 'sh' then
        local bash = find_executable('bash')

        if not bash then
            return
        end

        run_in_terminal(
            {
                bash,
                src,
            },
            src_dir
        )

        return
    end

    ---------------------------------------------------------------------------
    -- R
    ---------------------------------------------------------------------------

    if ft == 'r' then
        local rscript = find_executable('Rscript')

        if not rscript then
            return
        end

        run_in_terminal(
            {
                rscript,
                src,
            },
            src_dir
        )

        return
    end

    ---------------------------------------------------------------------------
    -- Graphviz
    ---------------------------------------------------------------------------

    if ft == 'dot' then
        local dot = find_executable('dot')

        if not dot then
            return
        end

        local output = vim.fs.joinpath(
            src_dir,
            src_stem .. '.svg'
        )

        run_system(
            {
                dot,
                '-Tsvg',
                src,
                '-o',
                output,
            },
            src_dir,
            function()
                local _, open_err =
                    vim.ui.open(output)

                if open_err then
                    vim.notify(
                        open_err,
                        vim.log.levels.ERROR,
                        { title = 'Runner' }
                    )
                end
            end
        )

        return
    end

    ---------------------------------------------------------------------------
    -- Unsupported
    ---------------------------------------------------------------------------

    vim.notify(
        'Unsupported filetype: ' .. ft,
        vim.log.levels.WARN,
        { title = 'Runner' }
    )
end

return M
