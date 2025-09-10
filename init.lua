-- NeoVim config file
-- César Godinho 2024
-- Current features / plugins:
--  - Lazy.vim plugin loader
-- 	- Mason lsp installer with auto config
-- 	- Fzf
-- 	- Treesitter
-- 	- Undo tree
-- 	- Under cursor line highlight
--	- Custom lsp virtual lines
--  - Custom auto-complete
--  - Custom git blame
--  - Custom simple build integration

-- Global settings for the editor
vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.relativenumber = true

-- Set the leader key we use (stick to space, nvchad style)
vim.g.mapleader = ' '

-- Setup lazyvim
local lazy = {}

function lazy.try_install(path)
	if not vim.loop.fs_stat(path) then
		print('Installing lazy.nvim....')
    	vim.fn.system({
      		'git',
      		'clone',
      		'--filter=blob:none',
      		'https://github.com/folke/lazy.nvim.git',
      		'--branch=stable', -- latest stable release
      		path,
    	})
  	end
end

function lazy.setup(plugins)
  	if vim.g.plugins_ready then
    	return
  	end

  	lazy.try_install(lazy.path)

  	vim.opt.rtp:prepend(lazy.path)

  	require('lazy').setup(plugins, lazy.opts)
  	vim.g.plugins_ready = true
end

lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

lazy.setup({
	-- Setup a status line
	{'nvim-lualine/lualine.nvim', dependencies = {'nvim-tree/nvim-web-devicons'}},

	-- Setup the theme
	{"ellisonleao/gruvbox.nvim", priority = 1000 , config = true},

	-- LSP Installer
	{"williamboman/mason.nvim"},
	{"williamboman/mason-lspconfig.nvim"},
	{"echasnovski/mini.completion", version = '*'},
	{"neovim/nvim-lspconfig"},

	-- Fzf search
	{"ibhagwan/fzf-lua", dependencies = { "nvim-tree/nvim-web-devicons" }},

	-- Tree-sitter
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},

	-- Comments highlighter
	{"folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }},

	-- Undo tree
	{"mbbill/undotree"},

	-- Auto comments
	{"numToStr/Comment.nvim"},

	-- Cursor position highlighter
	{
		"mawkler/modicator.nvim",
		dependencies = 'ellisonleao/gruvbox.nvim',
		init = function()
			vim.o.cursorline = true
			vim.o.number = true
			vim.o.termguicolors = true
		end,
		opts = {
			show_warnings = true,
		}
	},

	-- Custom dashboard
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			require('dashboard').setup({
				-- theme = 'doom',
				-- config = {
				-- 	header = {'WELCOME'},
				-- 	-- center = {{}},
				-- 	-- footer = {}
				-- }
			})
		end,
	},

	-- Custom diagnostic lines
	{ "maan2003/lsp_lines.nvim" },

	-- Trouble diagnostics
	{
		"folke/trouble.nvim",
		opts = {
			keys = {
				["<CR>"] = "jump_close",
			}
		},
		cmd = "Trouble",
		keys = {
			{
			  "<leader>fx",
			  "<cmd>Trouble diagnostics toggle filter.buf=0<cr><cmd>sleep 100m<cr><C-w><C-w>",
			  desc = "Buffer Diagnostics (Trouble)",
			},
		}
	},

	-- Git blame
	{
		"f-person/git-blame.nvim",
		event = "VeryLazy",
		opts = {
			-- your configuration comes here
			-- for example
			enabled = true,  -- if you want to enable the plugin
			message_template = "<date> • <author> • <summary> • <<sha>>", -- template for the blame message, check the Message template section for more options
			date_format = "%r", -- template for the date, check Date format section for more options
			virtual_text_column = 0,  -- virtual text start column, check Start virtual text at column section for more options
			message_when_not_committed = 'Line not commited... Local changes only.',
			display_virtual_text = 0
		},
	},

	-- Float term for lazygit
	{ "voldikss/vim-floaterm" },
})

local git_blame = require('gitblame')
require('lualine').setup({
	options = { theme = 'gruvbox' },
	sections = {
		lualine_c = {
			{ git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available }
		}
	}
})

-- Setup the theme
vim.o.background = "dark"
require("gruvbox").setup()
vim.cmd([[colorscheme gruvbox]])

require("mason").setup()

require("mini.completion").setup()
-- require("coq").setup()
require("mason-lspconfig").setup {}

-- Config fzf and keybinds
require("fzf-lua").setup({'fzf-native'})
vim.keymap.set('n', '<leader>ff', require('fzf-lua').files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>fw', require('fzf-lua').live_grep , { desc = 'Find Words' })
vim.keymap.set('n', '<leader>fz', require('fzf-lua').lgrep_curbuf , { desc = 'Find Buffer' })
vim.keymap.set('n', '<leader>fr', require('fzf-lua').lsp_references, { desc = 'Find References' })
vim.keymap.set('n', '<leader>fs', require('fzf-lua').lsp_document_symbols, { desc = 'Find Document Symbols' })
vim.keymap.set('n', '<leader>fa', require('fzf-lua').lsp_live_workspace_symbols, { desc = 'Find All Symbols'})
vim.keymap.set('n', '<leader>fd', require('fzf-lua').diagnostics_document, { desc = 'Document Diagnostics' })
vim.keymap.set('n', '<leader>ft', '<cmd>Trouble todo<CR><cmd>sleep 100m<CR><C-w><C-w>', { desc = 'Find Todo' })

-- Config tree-sitter
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"lua",
		"c",
		"cpp",
		"cmake",
		"fortran",
		"python",
		"gitignore",
	},
	highlight = { enable = true },
	indent = { enable = true },
})

-- Setup TODO comments
require('todo-comments').setup()

-- Setup undo tree
vim.keymap.set('n', '<leader>u', '<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>')

-- Setup auto comment
require('Comment').setup({
	toggler = {
        ---Line-comment toggle keymap
        line = '<leader>/',
	}
})

-- Setup Iluminator
require('modicator').setup()

-- Configure diagnostics icons
vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = 'ER',
			[vim.diagnostic.severity.WARN] = 'WN',
		},
		-- linehl = {
		-- 	[vim.diagnostic.severity.ERROR] = 'ErrorMsg',
		-- },
		-- numhl = {
		-- 	[vim.diagnostic.severity.WARN] = 'WarningMsg',
		-- },
	},
	virtual_text = false
})

-- Configure custom lsp lines
require('lsp_lines').setup()

-- Configure trouble
require('trouble').setup({
	-- opts = {
	-- 	keys = {
	-- 		["<CR>"] = "jump_close",
	-- 	}
	-- },
})

-- Setup gitblame
require('gitblame').setup({
    -- enabled = false,
})

-- Add some floating terminal window for fbuild
-- Fast build just looks if there is a file under the cwd named `.fbuild`
-- If not, the command is just ignored printing fbuild not setup for current project
-- This is just a simple tool to run the project preferred configure/build system

local function setup_fbuild()
	local cwd = vim.fn.getcwd()
	local cfg_file = io.open(cwd .. '/.fbuild.lua', 'r')
	if cfg_file == nil then
		return
	end

	local fbf = dofile(cwd .. '/.fbuild.lua')

	vim.api.nvim_create_user_command('FBuild', function() fbf(cwd, vim) end, {})
end

setup_fbuild()

-- Now do a similar setup for lazygit (if installed)
if vim.fn.executable('lazygit') == 1 then

	vim.keymap.set('n', '<leader>lg', '<cmd>FloatermNew --height=0.8 --width=0.8 --wintype=float --title=LazyGit --autoclose=2 lazygit<cr>', { desc = 'Open Lazygit' })
end
