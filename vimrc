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

colorscheme zendo

filetype plugin indent on

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

" always show signcolumns
set signcolumn=yes

" Numbers
set number

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Better escaping from terminals
tnoremap <ESC><ESC> <C-\><C-n>

" Buffers can stay 'open' if not in a window
set hidden
" Buffer switching is fast as hell
nnoremap <C-l> :bnext<CR>
nnoremap <C-h> :bprev<CR>

nnoremap <Esc><Esc> :<C-u>nohlsearch<CR>

" FUN WITH LEADER COMMANDS

" Reload vimrc
nnoremap <Leader>vr :source ~/.vimrc<CR>

" Quick timestamp for logs etc.
nnoremap <leader>d :put =strftime('%FT%T%z')<CR>

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

" Lightline
let g:lightline = {
  \ 'colorscheme': 'zendo',
  \ }

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

" Coc
" Manually fix every god damned thing with :Format
nnoremap <leader>f :CocCommand eslint.executeAutofix<CR>
" Jump to problems
nmap <silent> <C-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <C-j> <Plug>(coc-diagnostic-next)
" Type definition
nnoremap <silent> K :call CocAction('doHover')<CR>
" More goto actions
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
" Code actions
nmap <leader>do <Plug>(coc-codeaction)
" Rename a symbol
nmap <leader>rn <Plug>(coc-rename)

" Show / fuzzy search symbols
nnoremap <silent> <C-O>  :<C-u>CocList outline<cr>
" Show all diagnostics
nnoremap <silent> <C-A>  :<C-u>CocList diagnostics<cr>

" Clap 👏
" Fuzzy file search
nnoremap <C-P> :Clap files<CR>
" Fuzzy buffer search
nnoremap <C-B> :Clap buffers<CR>
" Yank list
nnoremap <C-Y> :Clap yanks<CR>
" Grep!
nnoremap <C-G> :Clap grep<CR>
" Marks list
nnoremap <C-M> :Clap marks<CR>
" Bigger clap window
let g:clap_layout = { 'relative': 'editor' }
" Fun empty message
let g:clap_no_matches_msg = 'no dice'
" Insert only!
let g:clap_insert_mode_only = v:true

" Open-Browser-Github
let g:openbrowser_github_always_used_branch = 'master'
nnoremap <leader>g :OpenGithubFile<CR>

" Localvimrc
" Stop asking me about local vimrc
let g:localvimrc_persistent = 2
