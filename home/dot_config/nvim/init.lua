-- Based on github.com/nvim-lua/kickstart.nvim

-- ==========================================================
-- SECTION 1: FOUNDATION
-- Core Neovim settings
-- ==========================================================
do 
  -- Enable faster startup by caching compiled Lua modules.
  vim.loader.enable()

  -- Remap leader & local leader
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to false if no nerdfonts installed
  vim.g.have_nerd_font = true

  -- [[ Setting Options ]]

  -- Show line numbers
  vim.o.number = true
  -- For relative line numbers
  -- vim.o.relativenumber = true

  -- Enable mouse mode
  vim.o.mouse = 'a'

  vim.o.showmode = false

  -- Sync clipboard between OS & Neovim
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Wrapped lines are at same indent level
  vim.o.breakindent = true

  vim.o.wrap = true

  -- Enable undo/redo changes after file has been closed
  vim.o.undofile = true

  -- Case-insensitive searching
  -- Override with '\C' or 1+ capital letters in search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  vim.o.signcolumn = "auto"

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- How new splits are opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- How Neovim displays whitespace characters
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } 

  -- Preview substitutions as you type
  vim.o.inccommand = 'split'

  -- Show which line cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above & below the cursor
  vim.o.scrolloff = 10

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  -- See `:help 'confirm'`
  vim.o.confirm = true

  -- [[ Basic Keymaps ]]

  -- Clear search highlights in normal mode
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Diagnostic Config & Keymaps
  -- See ':help vim.diagnostics.Opts'
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Can switch between these as you prefer
    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- Default mapping to exit terminal mode is '<C-\><C-n>'
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- Simplify split navigation to 'CTRL+<hjkl>'
  vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
  vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })

  -- [[ Basic Autocommands ]]
  -- Highlight when yanking text
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking text',
    group = vim.api.nvim_create_augroup('kickstart_highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- ==========================================================
-- SECTION 2: PLUGIN MANAGER INTRO
-- ==========================================================

do
  -- To inspect plugin state & pending updates
  -- :lua vim.pack.upddate(nil, { offline = true })

  -- To update plugins
  -- :lua vim.pack.update()

  -- Following autocommands run build steps for certain plugins after they're installed or updated.

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated & runs the appropriate build command for that plugin if necessary.
  --
  -- See :help vim.pack-events
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function (ev)
      local name = ev.data.spec.name
      local kind = ev.data.kindd
      if kind ~= 'install' and kind ~= 'update' then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { make }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then
          vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdadte'
        return
      end
    end,
  })
end

-- Helper funtion since most plugins are hosted on GitHub
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ==========================================================
-- SECTION 3: UI / CORE UX PLUGINS
-- ==========================================================

do
  -- Guess indent
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  if vim.g.have_nerd_font then vim.pack.add { gh 'nvim-tree/nvim-web-devicons'} end

  -- Gitsigns
  vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
  require('gitsigns').setup {
    signs = {
      add = { text = '+ ' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
  }

  -- Todo Comments
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup { signs = false }

  -- [[ Colorscheme ]]
  vim.pack.add({
    {
      src = gh 'rose-pine/neovim',
      name = 'rose-pine'
    },
  })
  require('rose-pine').setup({})
  vim.cmd.colorscheme 'rose-pine-dawn'

  -- [[ mini.nvim ]]
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- Better Around/Inside textobjects
  require('mini.ai').setup {
    -- Following avoids conflicts with built-in incremental selection mappings
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- Edit surrounding brackets, quotes, etc.
  require('mini.surround').setup()

  local statusline = require 'mini.statusline'
  -- set 'use_icons' to true if a NF is installed
  statusline.setup { use_icons = vim.g.have_nerd_font }

  statusline.section_location = function() return '%2l:%-2v' end

  -- mini.clue
  local miniclue = require 'mini.clue'
  miniclue.setup({
    triggers = {
      -- Leader
      { mode = { 'n', 'x' }, keys = '<Leader>' },
      -- '[' and ']'
      { mode = 'n', keys = '[' },
      { mode = 'n', keys = ']' },

      -- Built-in completion
      { mode = 'i', keys = '<C-x>' },

      -- 'g'
      { mode = 'i', keys = 'g' },

      -- Marks
      { mode = { 'n', 'x' }, keys = "'" },
      { mode = { 'n', 'x' }, keys = '`' },

      -- 'z'
      { mode = { 'n', 'x' }, keys = 'z' },
    },

    -- Built-in clues
    clues = {
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.z(),

      -- Leader mapping groups
      { mode = 'n', keys = '<leader>s', desc = '+Search/Sessions' }
    },
  })

  -- mini.sessions
  local minisessions = require 'mini.sessions'
  minisessions.setup()

  local nmap_leader = function(suffix, rhs, desc)
    vim.keymap.set('n', '<leader>' .. suffix, rhs, { desc = desc })
  end

  local session_new = 'vim.ui.input({ prompt = "Sessions name: "}, MiniSessions.write)'

  nmap_leader('sd', '<Cmd>lua  MiniSessions.select("delete")<CR>', 'Delete')
  nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>', 'New')
  nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>', 'Read')
  nmap_leader('sR', '<Cmd>lua MiniSessions.restart()<CR>', 'Restart ')
  nmap_leader('sW', '<Cmd>lua MiniSessions.write()<CR>', 'Write current')

  -- mini.starter
  local starter = require 'mini.starter'
  starter.setup()
end

-- ==========================================================
-- SECTION 4: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings
-- ==========================================================

do
  -- Telescope
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
    gh 'nvim-telescope/telescope-file-browser.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

  vim.pack.add(telescope_plugins)

  require('telescope').setup {
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  -- Install Telescope extensions if installed
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')
  pcall(require('telescope').load_extension, 'file_browser')

  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sF', "<Cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = '[S]earch [F]iles (File Browser)' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- Add Telescope-based LSP pickers when an LSP attaches to a buffer
  -- NOTE: Update mappings here if I switch pickers.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      -- Find references for word under cursor
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

      -- Jump to implementation of word under cursor
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

      -- Jump to definition of word undder cursor
      -- (Where the variable is declared, function defined, etc.)
      -- `<C-t>` to jump back
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition'})

      -- Fuzzy find all the symbols in current workspace
      -- Similar to document symbols, but searches entire project
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

      -- Jump to the type of the word under cursor.
      -- Useful when not sure what type a variable is & you want to see
      -- the definition of it's *type* instead of where it was *defined*.
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  -- Override default behavior & theme when searching
  vim.keymap.set('n', '<leader>/', function()
    -- You can pass additional config to Telescope to change the theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = true,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set( 'n', '<leader>s/', function() builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files', } end, { desc = '[S]earch [/] in Open Files' })
  --
  -- Shortcut for searching Neovim config files
  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files'})

end

-- ===========================================================
-- SECTION 5: LSP
-- LSP keymaps, server configuration, Mason tools installation
-- ===========================================================
do
  -- [[ LSP Config ]]

  -- Fidget adds useful status updates for LSP.
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {
    {
      progress = {
        supress_on_insert = true,
      },
      window = {
        align = "top",
        -- avoid = {},
      },
    }
  }

  -- Runs when an LSP attaches to a particular buffer
  -- Configures the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename variable under cursor
      -- (Most LSPs support renaming across files)
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action
      -- Cursor usually needs to be on top of an error
      -- or a suggestion from the LSP to activate
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- WARN: This is NOT Goto Definition, it's DECLARATION
      -- Ex: in C this would go to the header
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- The next 2 autocommands highlight references of what 
      -- is under cursor when it rests there for a little while.
      --
      -- When you move cursor, the highlights will clear (2nd autocommand)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorModedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- Toggle inlay hints if LSP supports them
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- Enable the following LSPs
  local servers = {
    bash_language_server = {},
    golangci_lint_ls = {},
    gopls = {},
    marksman = {},
    pyright = {},

    -- Special Lua config, recommended by Neovim help docs
    lua_language_server = {
      on_init = function(client)
        client.server_capabilities.ddocumentFormattingProvider = false
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            -- NOTE: this is a lot slower & will cause issues when working on personal config
            -- See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
              '${3rd}/luv/library',
              '${3rd}/busted/library',
            }),
          },
        })
      end,

      settings = {
        Lua = {
          format = { enable = false }, -- Disables formatting (done by stylelua)
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  -- Automatically install LSPs & related tools to Neovim's stdpath
  require('mason').setup{}

  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- NOTE: Add other tools here for Mason to install
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end

-- ========================================================
-- SECTION 6: FORMATTING
-- conform.nvim setup & keymap
-- ========================================================
--
do
  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Filetypes to autoformat
      local enabled_filetypes = {
        lua = true,
        go = true,
        python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      -- Use external formatters if configured below, otherwise use LSP formatting.
      -- Set to `false` to disable LSP formatting.
      lsp_format = 'fallback',
    },
    -- Specify external formatters
    formatters_by_ft = {
      -- TODO: Add external formatters.
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end

-- ========================================================
-- SECTION 7: AUTOCOMPLETE & SNIPPETS
-- blink.cmp & luasnip setup
-- ========================================================
do
  -- [[ Snippet Engine ]]
  --
  -- NOTE: Can specify plugins using a version range for its git tag.
  -- See `:help vim.version.range()` for more info
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  require('luasnip.loaders.from_vscode').lazy_load()

  -- [[ Autocomplete Engine ]]
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    keymap = {
      preset = 'default',

      -- For advanced Luasnip keymaps see:
      -- https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to enure icons are pproperly aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- Default: `<C-Space>` to show documentation.
      -- Set `auto_show = true` to show after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    snippets = { preset = 'luasnip' },

    -- blink.cmp includes optional, but reccommendded Rust fuzzy matcher
    -- It automatically downloadds a prebuilt binary when enabled.
    -- Can enable via `implementation = 'prefer_rust_with_warng'`
    fuzzy = { implementation = 'lua' },

    -- Show signature help window while you type arguments for a function
    signature = { enabled = true },
  }
end

-- ========================================================
-- SECTION 8: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation
-- ========================================================

do
  -- [[ Configure Treesitter ]]
  -- NOTE: Can specify a branch or specific commit
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Install basic parsers
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  require('nvim-treesitter').install(parsers)

  local function treesitter_try_attach(buf, language)
    -- Check if parser exists & load it.
    if not vim.treesitter.language.add(language) then return end
    -- Enable syntax highlighting & other treesitter features.
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldmethod = 'expr'

    -- Check if treesitter indentation is available in current language.
    -- Enable it incase there is no indent query. `indentexpr` fallsback to vim's builtin.
    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match
      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

      if vim.tbl_contains(installed_parsers, language) then
        -- Enable parser if it's installed
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        -- Try to enable treesitter features in case the parser exists but isn't available
        treesitter_try_attach(buf, language)
      end
    end,
  })
end

-- ========================================================
-- SECTION 9: OTHER PLUGINS
-- ========================================================

do
  vim.pack.add { gh 'windwp/nvim-autopairs' }
  require('nvim-autopairs').setup {}

  -- [[ DAP ]]
  vim.pack.add {
    gh 'mfussenegger/nvim-dap',
    gh 'rcarriga/nvim-dap-ui',
    gh 'nvim-neotest/nvim-nio',
    gh 'jay-babu/mason-nvim-dap.nvim',
    gh 'leoluz/nvim-dap-go',
  }

  local dap = require('dap')
  local dapui = require('dapui')

  -- Debugging keymaps
  vim.keymap.set('n', '<F5>', function() dap.continue() end, { desc = 'Debug: Start/Continue' })
  vim.keymap.set('n', '<F1>', function() dap.set_into() end, {desc = 'Debug: Step Into' })
  vim.keymap.set('n', '<F2>', function() dap.step_over() end, { desc = 'Debug: Step Over' })
  vim.keymap.set('n', '<F3>', function() dap.step_out() end, {desc = 'Debug: Step Out' })
  vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
  vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })

  -- Toggle to see last session result. W/out you can't see session output when there are unhandled exceptions.
  vim.keymap.set('n', '<F7>', function() dapui.toggle() end, { desc = 'Debug: See last session result' })

  require('mason-nvim-dap').setup {
    -- Makes a best effort to setup the various debuggers w/
    -- resonable debug configs
    automatic_installation = true,

    -- Pass additional config to handlers
    -- See mason-nvim-dap README for more info.
    handlers = {},

    -- Check that required programs are already installed
    ensure_installed = {
      -- TODO: Update debugers for languages
      -- 'delve',
    },
  }

  dapui.setup {
    -- Set icons to characters that are more likely to work in every terminal.
    --    Feel free to remove or use ones that you like more! :)
    --    Don't feel like these are good choices.
    icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
    ---@diagnostic disable-next-line: missing-fields
    controls = {
      icons = {
        pause = '⏸',
        play = '▶',
        step_into = '⏎',
        step_over = '⏭',
        step_out = '⏮',
        step_back = 'b',
        run_last = '▶▶',
        terminate = '⏹',
        disconnect = '⏏',
      },
    },
  }

  dap.listeners.after.event_initialized['dapui_config'] = dapui.open
  dap.listeners.before.event_terminated['dapui_config'] = dapui.close
  dap.listeners.before.event_exited['dapui_config'] = dapui.close

  -- NOTE: Golang specific config
  require('dap-go').setup {
    -- delve = {
    -- On Windows, ddelve must run attached to not crash.
    -- detached = vim.fn.has 'win32' == 0,
    -- },
  }

  -- chezmoi.nvim
  vim.pack.add { gh 'xvzc/chezmoi.nvim' }
  require('chezmoi').setup({})

    -- [[ Markdown Plugins ]]
  vim.pack.add { gh 'yaocccc/nvim-hl-mdcodeblock.lua' }
  require('hl-mdcodeblock').setup({
    bg = "#f2e9e1",
  })

  -- View Mermaid diagrams
  vim.pack.add { gh 'kevalin/mermaid.nvim' }
  require('mermaid').setup({
    preview = {
      theme = 'forest',
    }
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "mermaid",
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      vim.keymap.set('n', '<leader>mp', '<Cmd>MermaidPreview<CR>', { buffer = buf, desc = "[M]ermaid [P]review" })
      vim.keymap.set('n', '<leader>mf', '<Cmd>MermaidFormat<CR>', { buffer = buf, desc = '[M]ermaid [F]ormat'})
    end
  })
end
-- vim: ts=2 sts=2 sw=2 et
