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
      },
    })
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

          local builtin = require 'telescope.builtin'
          vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
          vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
          vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
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
  require('fidget').setup {}

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
      map('grD', vim.lsplbuf.declaration, '[G]oto [D]eclaration')

      -- The next 2 autocommands highlight references of what 
      -- is under cursor when it rests there for a little while.
      --
      -- When you move cursor, the highlights will clear (2nd autocommand)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHolddI' }, {
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
    gopls = {},
    pyright = {},

    -- Special Lua config, recommended by Neovim help docs
    lua_ls = {
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
                -- vim: ts=2 sts=2 sw=2 et
