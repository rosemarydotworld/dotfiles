" Leader
let mapleader = " "

set backspace=2       " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile        " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler             " show the cursor position all the time
set cursorline
set showcmd           " display incomplete commands
set incsearch         " do incremental searching
set nohlsearch        " no search highlighting
set laststatus=2      " Always display the status line
set autowrite         " Automatically :write before running commands
set showmode          " Show the current mode
set mouse=nicr        " scroll with the mouse if i feel like it
set nowrap            " don't wrap
set undofile          " Maintain undo history between sessions
set undodir=~/.vim/undodir

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Theme
syntax enable
" for vim 7
set t_Co=256

" for vim 8
if (has("termguicolors"))
  set termguicolors
endif

let ayucolor="mirage"
colorscheme ayu
set background=dark

" Custom statusline; I am the worst
if filereadable(expand("~/.vimrc.line"))
  source ~/.vimrc.line
endif

filetype plugin indent on

" Use 'ag' for searching
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif
" Don't jump to the first result
cnoreabbrev Ack Ack!
nnoremap <Leader>A :Ack!<Space>

autocmd BufWritePre * %s/\s\+$//e

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

" Softtabs, 4 spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent " Do smart indenting when starting a new line

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use italics!
highlight Comment cterm=italic

" Use one space, not two, after punctuation.
set nojoinspaces

" Numbers
set number
set relativenumber
set numberwidth=5
" Use relative line numbers except in Insert mode
augroup toggle_relative_number
autocmd InsertEnter * :setlocal norelativenumber
autocmd InsertLeave * :setlocal relativenumber

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Better escaping from terminals
tnoremap <ESC><ESC> <C-\><C-n>

" Manually fix every god damned thing
nmap <leader>F <Plug>(ale_fix)
" Jump between ale complaints quickly
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" Buffers can stay 'open' if not in a window
set hidden
" Buffer switching is fast as hell
nnoremap <C-l> :bnext<CR>
nnoremap <C-h> :bprev<CR>
" Close buffers quickly
nnoremap <C-x> :bd!<CR>
" BufTabLine settings
let g:buftabline_show = 1
" BufTabLine colors
hi BufTabLineFill guibg=#3D4759
hi BufTabLineActive guibg=#3D4759
hi BufTabLineHidden guibg=#3D4759

" Autocomplete
let g:deoplete#enable_at_startup = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" Fuzzy file search
let g:Lf_ShortcutF = '<C-P>'
" Full path search by default
let g:Lf_DefaultMode = 'FullPath'
" Fuzzy buffer search
let g:Lf_ShortcutB = '<C-B>'
" No separators for LeaderF
let g:Lf_StlSeparator = { 'left': '', 'right': '' }
" I don't need that big of a window
let g:Lf_WindowHeight = 0.3
" LeaderF colorscheme
let g:Lf_StlPalette = {
            \   'stlName': {
            \       'gui': 'bold',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'bold',
            \       'ctermfg': '22',
            \       'ctermbg': '157'
            \   },
            \   'stlCategory': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '210'
            \   },
            \   'stlNameOnlyMode': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '227'
            \   },
            \   'stlFullPathMode': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '147'
            \   },
            \   'stlFuzzyMode': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '227'
            \   },
            \   'stlRegexMode': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '121'
            \   },
            \   'stlCwd': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': '195',
            \       'ctermbg': '241'
            \   },
            \   'stlBlank': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': 'NONE',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': 'NONE',
            \       'ctermbg': '237'
            \   },
            \   'stlLineInfo': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '195'
            \   },
            \   'stlTotal': {
            \       'gui': 'NONE',
            \       'font': 'NONE',
            \       'guifg': '#607080',
            \       'guibg': '#242B38',
            \       'cterm': 'NONE',
            \       'ctermfg': '16',
            \       'ctermbg': '149'
            \   }
\ }

" Stop asking me about local vimrc
let g:localvimrc_persistent = 2

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Language Specific
" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Use lua highlighting for pico8 cartridges
au BufNewFile,BufRead *.p8 set filetype=lua
