" Leader
let mapleader = " "

set backspace=2       " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile        " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set showcmd           " display incomplete commands
set incsearch         " do incremental searching
set laststatus=2      " Always display the status line
set autowrite         " Automatically :write before running commands
set mouse=nicr        " scroll with the mouse if i feel like it
set nowrap            " don't wrap
set undofile          " Maintain undo history between sessions
set undodir=~/.vim/undodir
set cc=0

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Theme
syntax enable
set termguicolors

set background=dark
colorscheme ayu

filetype plugin indent on

autocmd BufWritePre * %s/\s\+$//e

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

" Softtabs, 2 spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent " Do smart indenting when starting a new line

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use italics!
highlight Comment cterm=italic

" Use one space, not two, after punctuation.
set nojoinspaces

" always show signcolumns
set signcolumn=yes

" Numbers
set number
set relativenumber

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Buffers can stay 'open' if not in a window
set hidden

" Stop highlighting search!
nnoremap <silent><Esc> :<C-u>nohlsearch<CR>

" FUN WITH LEADER COMMANDS

" Reload vimrc
nnoremap <Leader>vr :source ~/.vimrc<CR>

" Let me get to Explore/netrw faster
nnoremap <leader>e :Explore<CR>

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" LANGUAGE SPECIFIC

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Use lua highlighting for pico8 cartridges
au BufNewFile,BufRead *.p8 set filetype=lua

" PLUGIN STUFF
"
" Lightline
let g:lightline = {
  \ 'colorscheme': 'ayu',
  \ }

" Motion
lua << EOF
require('hop').setup()
vim.api.nvim_set_keymap('n', '<Leader>s', "<cmd>lua require'hop'.hint_words()<cr>", {})
EOF

" Git signs
lua << EOF
require('gitsigns').setup()
EOF

" Clip menu
lua << EOF
require('neoclip').setup({
  history = 1000,
  filter = nil,
})
require('telescope').load_extension('neoclip')
EOF
nnoremap <leader>p :Telescope neoclip<CR>

" Completion
let g:coq_settings = { 'auto_start': v:true }

" Incsearch
" :h g:incsearch#auto_nohlsearch
set hlsearch
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" Bbye
" Close buffers quickly
nnoremap <C-x> :Bdelete!<CR>

" Formatting
nnoremap <leader>f <cmd>lua vim.lsp.buf.formatting()<CR>

" LSP
" Config
lua << EOF
local lspconf = require("lspconfig")
local coq = require("coq")

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
  local eslintrc = vim.fn.glob(".eslintrc*", 0, 1)

  if not vim.tbl_isempty(eslintrc) then
    return true
  end

  if vim.fn.filereadable("package.json") then
    if vim.fn.json_decode(vim.fn.readfile("package.json"))["eslintConfig"] then
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
    return vim.fn.getcwd()
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
EOF
" Ref / Def
nnoremap <silent>gd :Lspsaga lsp_finder<CR>
" Actions
nnoremap <silent><leader>do :Lspsaga code_action<CR>
" Docs
nnoremap <silent>K :Lspsaga hover_doc<CR>
" Signature
nnoremap <silent><leader>h :Lspsaga signature_help<CR>
" Rename
nnoremap <silent>gr :Lspsaga rename<CR>
" Diagnostics
nnoremap <silent><C-j> :Lspsaga diagnostic_jump_next<CR>
nnoremap <silent><C-k> :Lspsaga diagnostic_jump_prev<CR>

" Telescope
nnoremap <C-P> <cmd>Telescope find_files<cr>
nnoremap <C-G> <cmd>Telescope live_grep<cr>
nnoremap <C-B> <cmd>Telescope buffers<cr>
nnoremap <silent><leader>?? <cmd>Telescope help_tags<cr>
lua << EOF
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
EOF

" Open-Browser-Github
let g:openbrowser_github_always_used_branch = 'master'
nnoremap <leader>g :OpenGithubFile<CR>

" Editor config
let g:EditorConfig_disable_rules = ['max_line_length']

" Localvimrc
" Stop asking me about local vimrc
let g:localvimrc_persistent = 2
