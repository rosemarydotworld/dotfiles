-- This is my init.lua! I refuse to:
-- * Use vimscript
-- * Split this into multiple files
-- * Format it nicely
-- * Write the comments in a way that make sense to people other than me
-- Ok! Have fun!

-- Utilities! Stolen from Jesse Atkinson, who in turn stole from Chris Kipp
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
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Let's set some basic options
-- Visible stuff
opt("w", "number", true)
opt("o", "showcmd", true)
opt("o", "laststatus", 2)
opt("o", "signcolumn", "yes")
opt("o", "wrap", false)

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
  use "wbthomason/packer.nvim"

  -- Colorscheme!
  use "nvim-treesitter/nvim-treesitter"
  use "Luxed/ayu-vim"

  -- Lumpy Space Princess
  use "glepnir/lspsaga.nvim"
  use "neovim/nvim-lspconfig"

  -- Formatting
  use 'mhartington/formatter.nvim'

  -- Search and find
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  -- Line!
  use {
    'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }

  -- Pair 'em up
  use "tpope/vim-endwise"

  -- What's wrong??
  use({
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
  })

  -- It's a clipmenu
  use 'AckslD/nvim-neoclip.lua'

  -- Autocompletion
  use { 'ms-jpq/coq_nvim', branch = 'coq' }
  use { 'ms-jpq/coq.artifacts', branch = 'artifacts'}

  -- Nice netrw
  use 'tpope/vim-vinegar'
  -- Comment stuff out
  use 'tpope/vim-commentary'
  -- Allow some extra things to repeat with `.`
  use 'tpope/vim-repeat'
  -- Use `S` to surround objects with e.g. quotes
  use 'tpope/vim-surround'

  -- Gitgutters
  use 'lewis6991/gitsigns.nvim'

  -- Move!
  use 'phaazon/hop.nvim'
  use 'chaoren/vim-wordmotion'

  -- Allow for dispatching my browser
  use 'tyru/open-browser.vim'
  -- Open current file in github repo
  use 'tyru/open-browser-github.vim'
end)

-- Theming
if fn.has("termguicolors") == 1 then
  opt("o", "termguicolors", true)
end
opt("o", "background", "dark")
require("ayu")
cmd("colorscheme ayu")

-- :Explore! It's good, actually
map("", "<leader>e", ":Explore<cr>")

-- Easy config reload
map("n", "<leader>vr", ":source ~/.config/nvim/init.lua<cr>")
map("n", "<leader>vp", ":PackerInstall<cr>")

-- Jump to file in github
map("n", "<leader>g", ":OpenGithubFile<cr>")

-- LSP
local lspconf = require("lspconfig")
local coq = require("coq")

g.coq_settings = { auto_start = true and 'shut-up' }
vim.api.nvim_command('autocmd VimEnter * COQnow --shut-up') -- no idea why I need this with the above

-- these langs require same lspconfig so put em all in a table and loop through!
local servers = {"html", "cssls", "pyright"}

for _, lang in ipairs(servers) do
  lspconf[lang].setup {
    on_attach = on_attach,
    root_dir = vim.loop.cwd
  }
end

local saga = require 'lspsaga'

saga.init_lsp_saga {
  max_preview_lines = 24,
  finder_action_keys = {
    open = '<CR>', vsplit = 'v', split = 's', quit = '<Esc>', scroll_down = '<Down>', scroll_up = '<Up>'
  },
  code_action_keys = {
    quit = '<Esc>', exec = '<CR>'
  },
  rename_action_keys = {
    quit = '<Esc>', exec = '<CR>'
  },
}

-- Linting
local eslint = {
  lintCommand = "eslint_d -f unix --stdin --stdin-filename ${INPUT}",
  lintStdin = true,
  lintFormats = {"%f:%l:%c: %m"},
  lintIgnoreExitCode = true,
  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true
}

local function eslint_config_exists()
  local eslintrc = fn.glob(".eslintrc*", 0, 1)

  if not vim.tbl_isempty(eslintrc) then
    return true
  end

  if fn.filereadable("package.json") then
    if fn.json_decode(fn.readfile("package.json"))["eslintConfig"] then
      return true
    end
  end

  return false
end

lspconf.tsserver.setup(coq().lsp_ensure_capabilities({
  on_attach = function(client)
    if client.config.flags then
      client.config.flags.allow_incremental_sync = true
    end
    client.resolved_capabilities.document_formatting = false
  end
}))

lspconf.efm.setup {
  on_attach = function(client)
    client.resolved_capabilities.document_formatting = true
    client.resolved_capabilities.goto_definition = false
  end,
  root_dir = function()
    if not eslint_config_exists() then
      return nil
    end
    return fn.getcwd()
  end,
  settings = {
    languages = {
      javascript = {eslint},
      javascriptreact = {eslint},
      ["javascript.jsx"] = {eslint},
      typescript = {eslint},
      ["typescript.tsx"] = {eslint},
      typescriptreact = {eslint}
    }
  },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "typescriptreact"
  },
}

map("n", "gd", "<cmd>Lspsaga lsp_finder<cr>")
map("n", "<leader>d", "<cmd>Lspsaga code_action<cr>")
map("n", "K", "<cmd>Lspsaga hover_doc<cr>")
map("n", "<leader>h", "<cmd>Lspsaga signature_help<cr>")
map("n", "gr", "<cmd>Lspsaga rename<cr>")
map("n", "<C-j>", "<cmd>Lspsaga diagnostic_jump_next<cr>")
map("n", "<C-k>", "<cmd>Lspsaga diagnostic_jump_prev<cr>")

-- Formatting
require('formatter').setup({
  filetype = {
    javascript = {
      -- prettier
      function()
        return {
          exe = "prettier",
          args = {"--stdin-filepath", fn.fnameescape(vim.api.nvim_buf_get_name(0)), '--single-quote'},
          stdin = true
        }
      end
    },
    typescript = {
      -- prettier
      function()
        return {
          exe = "eslint_d",
          args = {},
          stdin = true
        }
      end
    },
  }
})
map("", "<leader>f", "<cmd>Format<cr>")

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

vim.cmd("autocmd User LspProgressUpdate let &ro = &ro")

require("lualine").setup({
  options = {
    theme = "ayu_dark",
    icons_enabled = true,
    section_separators = { "", "" },
    component_separators = { "", "" },
    -- section_separators = {"", ""},
    -- component_separators = {"", ""}
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = { { "diagnostics", sources = { "nvim_lsp" } }, "filename" },
    lualine_x = { "filetype", lsp_progress },
    lualine_y = { clock },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
})

-- Neoclip
require('neoclip').setup({
  history = 1000,
  filter = nil,
  -- require'lspconfig'.tsserver.setup{}
})
require('telescope').load_extension('neoclip')
map("n", "<leader>p", ":Telescope neoclip<cr>")

-- Gotta go fast
require('hop').setup()
map('n', '<Leader>s', "<cmd>lua require'hop'.hint_words()<cr>", {})

-- More for telescope
local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
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
  }
}
map("", "<C-P>", "<cmd>Telescope find_files<cr>")
map("", "<C-G>", "<cmd>Telescope live_grep<cr>")
map("", "<C-B>", "<cmd>Telescope buffers<cr>")
