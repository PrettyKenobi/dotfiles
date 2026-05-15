-- Personal migration of https://github.com/nvim-lua/kickstart.nvim for Neovim v0.12

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
--
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
	float = { boarder = 'rounded', source = 'if_many' },
	underline = { severity = { min = vim.diagnostic.severity.WARN } },

	virtual_text = false, -- Text shows up at the end of the line
	virtual_line = true, -- Text shows up underneath the line

	-- Auto open the float so you can easily read the errors when jumping with '[d' & ']d'
	jump = { float = true },
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
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function() vim.hl.on_yank() end,
})

-- [[ Plugins using vim.pack ]]

-- Treesitter installation hook workaround
vim.api.nvim_create_autocmd('PackChanged', { callback = function(ev)
	local name, kind = ev.data.spec.name, ev.data.kind
	if name == 'nvim-treesitter' and kind == 'update' then
		if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
		vim.cmd('TSUpdate')
	end
end })

vim.pack.add({
	'https://github.com/rose-pine/neovim',
	'https://github.com/nvim-mini/mini.nvim',
	'https://github.com/neovim/nvim-lspconfig',
	'https://github.com/nvim-treesitter/nvim-treesitter',
	'https://github.com/mason-org/mason.nvim',
	{
		src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
		version = vim.version.range('3')
	},
	-- neo-tree dependencies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	-- optional, but recommended
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/tttol/md-outline.nvim",
})

require('rose-pine').setup()
vim.cmd.colorscheme('rose-pine-dawn')
require('mason').setup()
require('nvim-treesitter').install({
	'bash',
	'go',
	'json',
	'kdl',
	'lua',
	'markdown',
	'markdown_inline',
	'mermaid',
	'nu',
	'python',
	'regex',
	'xml',
	'yaml',
})

-- Mini modules
--
require('mini.ai').setup()
require('mini.comment').setup()

require('mini.completion').setup()
-- Helpful with completion module
require('mini.icons').setup()

require('mini.operators').setup()
require('mini.pairs').setup()

-- Snippets setup

local gen_loader = require('mini.snippets').gen_loader
require('mini.snippets').setup({
	snippets = {
		gen_loader.from_file('~/.config/nvim/snippets/global.json'),
		gen_loader.from_lang(),
	}
})

--require('mini.surround').setup()

-- Like Which-Key
local miniclue = require('mini.clue')
miniclue.setup({
	triggers = {
		{ mode = { 'n', 'x' }, keys = '<Leader>' },
		{ mode = { 'n', 'x' }, keys = 'g' },
		{ mode = { 'n', 'x' }, keys = "'" },
		{ mode = { 'n', 'x' }, keys = "`" },
		{ mode = { 'n', 'x' }, keys = 'x' },

		{ mode = 'n', keys = '[' },
		{ mode = 'n', keys = ']' },
		{ mode = 'n', keys = '<C-w>' },

		{ mode = 'i', keys = '<C-x>' },

		{ mode = { 'i', 'c' }, keys = '<C-r>' },
	},
	clues = {
		miniclue.gen_clues.square_brackets(),
	}
})
--require('mini.git').setup()
--require('mini.diff').setup()
-- Statusline
local statusline = require('mini.statusline')
statusline.setup { use_icons = vim.g.have_nerd_font }
statusline.section_location = function() return '%2l:%-2v' end

require('mini.starter').setup()

-- Setup for lazy loading
vim.pack.add({ 'https://github.com/nvim-mini/mini.misc'})
local misc = require('mini.misc')
local later = function (f) misc.safely('later', f) end
local on_event = function (ev, f) misc.safely('event:' .. ev, f) end

later(function()
	require('mini.cmdline').setup()
end)

on_event('InsertEnter', function ()
	require('mini.completion').setup()
	require('mini.surround').setup()
end)
-- Neotree keybinds
vim.keymap.set('n', '<Leader>t', ':Neotree<CR>', { desc = "[T]oggle Neotree"})


-- [[ LSPs ]]
-- Golang
vim.lsp.enable('golangci_lint_ls')
vim.lsp.enable('gopls')
vim.lsp.enable('gotests')

-- Lua
vim.lsp.enable('lua_ls')

-- Markdown
vim.lsp.enable('cbfmt')
vim.lsp.enable('marksman')
