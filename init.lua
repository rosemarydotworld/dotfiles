-- This is my init.lua! I refuse to:
-- * Use vimscript
-- * Split this into multiple files
-- * Format it nicely
-- * Write the comments in a way that make sense to people other than me
-- Ok! Have fun!

-- Utilities! Stolen from Jesse Atkinson, who in turn stole from Chris Kipp
local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local g = vim.g

local function opt(scope, key, value)
	local scopes = { o = vim.o, b = vim.bo, w = vim.wo }
	scopes[scope][key] = value
	if scope ~= "o" then
		scopes["o"][key] = value
	end
end

local function map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Let's set some basic options
-- Visible stuff
opt("w", "number", true)
opt("o", "showcmd", true)
opt("o", "laststatus", 2)
opt("o", "signcolumn", "yes")
opt("o", "wrap", false)
opt("o", "showmode", false)

-- Window management:
opt("o", "hidden", true)
opt("o", "splitbelow", true)
opt("o", "splitright", true)

-- I like the spacebar, it is the only key on my dumb little keyboard that is any bigger
g["mapleader"] = " "
g["maplocalleader"] = " "

-- I also like the mouse sometimes
opt("o", "mouse", "nicr")

-- Two spaces! Please!
opt("o", "tabstop", 2)
opt("o", "softtabstop", 2)
opt("o", "shiftwidth", 2)
opt("o", "expandtab", true)
opt("o", "smartindent", true)

-- Let's keep an undofile
opt("o", "autowrite", true)
opt("o", "undofile", true)
opt("o", "backup", false)
opt("o", "writebackup", false)
opt("o", "swapfile", false)

-- Fix multi-byte emoji
opt("o", "emo", false)

-- And now, plugins:
cmd([[packadd packer.nvim]])
require("packer").startup(function()
	-- Packer can manage itself as an optional plugin.
	use("wbthomason/packer.nvim")

	-- Colorscheme!
	use("nvim-treesitter/nvim-treesitter")
	use({
		"rose-pine/neovim",
		as = "rose-pine",
	})

	-- LSP
	use("neovim/nvim-lspconfig")
	use("nvim-lua/lsp-status.nvim")
	use("jose-elias-alvarez/null-ls.nvim")
	-- Formatting
	use("mhartington/formatter.nvim")

	-- Jinja specifically for njk files in Eleventy, mostly
	use("lepture/vim-jinja")

	-- Search and find
	use({
		"nvim-telescope/telescope.nvim",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	-- Lines!
	use({
		"hoob3rt/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	-- Get rid of buffers easily
	use("famiu/bufdelete.nvim")

	-- What's wrong??
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
	})

	-- Nice netrw
	use("tpope/vim-vinegar")
	-- Comment stuff out
	use("tpope/vim-commentary")
	-- Allow some extra things to repeat with `.`
	use("tpope/vim-repeat")

	-- Sandwiches! add, delete, or replace quotes, parens, etc.
	use("machakann/vim-sandwich")

	-- Registers
	use("tversteeg/registers.nvim")

	-- Simple tweak to highlighting and searching in file
	use("rktjmp/highlight-current-n.nvim")

	-- Gitgutters
	use({
		"lewis6991/gitsigns.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("gitsigns").setup()
		end,
	})

	-- Move!
	use("phaazon/hop.nvim")
	use("chaoren/vim-wordmotion")

	-- Allow for dispatching my browser
	use("tyru/open-browser.vim")
	-- Open current file in github repo
	use("tyru/open-browser-github.vim")
end)

-- Theming
if fn.has("termguicolors") == 1 then
	opt("o", "termguicolors", true)
end
cmd([[colorscheme rose-pine]])

-- Some mapping

-- :Explore! It's good, actually
map("", "<leader>e", ":Explore<cr>")

-- Easy config reload
map("n", "<leader>vr", ":source ~/.config/nvim/init.lua<cr>")
map("n", "<leader>vp", ":PackerInstall<cr>")

-- Jump to file in github
map("n", "<leader>g", ":OpenGithubFile<cr>")
-- Last file
map("n", "<leader><leader>", "<c-^>")

-- Clear search highlighting easily
map("n", "<backspace>", ":noh<cr>")

-- netrw is ephemeral
g.netrw_fastbrowse = 0

-- LSP
local lspconfig = require("lspconfig")
local lsp_status = require("lsp-status")
local null_ls = require("null-ls")
local futil = require("formatter.util")

-- Register this plugin that keeps track of progress messages.
-- This is used by the status line to show a spinner while the LSP is working.
lsp_status.register_progress()

-- Define all enabled LSPs.
--
-- Extra per-LSP settings are defined here, and they're merged with
-- common_settings before configuring each LSP.
local servers = {
	tsserver = {
		on_attach = function(client, bufnr)
			lsp_status.on_attach(client, bufnr)

			-- Disable `tsservers`'s formatting capability so that null-ls
			-- is registered as the only compatible formatter.
			client.resolved_capabilities.document_formatting = false
		end,
	},
}

-- Helper to conditionally register eslint handlers only if eslint is
-- configured. If eslint is not configured for a project, it just fails.
local function has_eslint_configured(utils)
	return utils.root_has_file(".eslintrc.js")
end

local common_settings = {
	on_attach = lsp_status.on_attach,
	capabilities = lsp_status.capabilities,
}

-- Register all the LSP servers.
for server, config in pairs(servers) do
	-- Set default client capabilities plus window/workDoneProgress
	config.capabilities = vim.tbl_extend("keep", config.capabilities or {}, lsp_status.capabilities)

	-- Merge per-LSP configs with the common settings, and use that:
	lspconfig[server].setup(vim.tbl_extend("keep", config, common_settings))
end

require("formatter").setup({
	filetype = {
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		typescript = {
			require("formatter.defaults.eslint_d"),
		},
		typescriptreact = {
			require("formatter.defaults.eslint_d"),
		},
	},
})

map("n", "<leader>f", "<cmd>FormatWrite<cr>")

-- Trouble!
map("n", "<leader>t", "<cmd>TroubleToggle<cr>")

-- Completion
opt("o", "completeopt", "menu,menuone,noselect")

-- Trouble
require("trouble").setup()

-- The line!
local function clock()
	return " " .. os.date("%H:%M")
end

local function lsp_progress()
	local messages = vim.lsp.util.get_progress_messages()
	if #messages == 0 then
		return
	end
	local status = {}
	for _, msg in pairs(messages) do
		table.insert(status, (msg.percentage or 0) .. "%% " .. (msg.title or ""))
	end
	local spinners = {
		"⠋",
		"⠙",
		"⠹",
		"⠸",
		"⠼",
		"⠴",
		"⠦",
		"⠧",
		"⠇",
		"⠏",
	}
	local ms = vim.loop.hrtime() / 1000000
	local frame = math.floor(ms / 120) % #spinners
	return table.concat(status, " | ") .. " " .. spinners[frame + 1]
end

cmd("autocmd User LspProgressUpdate let &ro = &ro")

require("lualine").setup({
	options = {
		theme = "rose-pine",
		icons_enabled = true,
		section_separators = { "", "" },
		component_separators = { "", "" },
		-- section_separators = {"", ""},
		-- component_separators = {"", ""}
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff" },
		lualine_c = { { "diagnostics", sources = { "nvim_diagnostic" } }, "filename" },
		lualine_x = {},
		lualine_y = { "filetype", lsp_progress },
		lualine_z = { clock },
	},
	inactive_sections = {
		lualine_a = { "filename", "diff" },
		lualine_b = {},
		lualine_c = {},
	},
})
map("n", "<c-x>", "<cmd>Bdelete<cr>")

-- Gotta go fast
require("hop").setup()
map("n", "<Leader>s", "<cmd>lua require'hop'.hint_words()<cr>", {})

-- More for telescope
local actions = require("telescope.actions")
require("telescope").setup({
	defaults = {
		file_ignore_patterns = { "node_modules" },
		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
			n = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
			},
		},
	},
	pickers = {
		buffers = {
			show_all_buffers = true,
			sort_lastused = true,
			mappings = {
				i = {
					["<c-x>"] = "delete_buffer",
				},
			},
		},
	},
})
map("", "<C-P>", "<cmd>Telescope find_files<cr>")
map("", "<C-G>", "<cmd>Telescope live_grep<cr>")
map("", "<C-B>", "<cmd>Telescope buffers<cr>")
