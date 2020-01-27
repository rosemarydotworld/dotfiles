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

colorscheme one
set background=dark

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
set relativenumber
set numberwidth=5
" Use relative line numbers except in Insert mode
augroup toggle_relative_number
autocmd InsertEnter * :setlocal norelativenumber
autocmd InsertLeave * :setlocal relativenumber

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

" FUN WITH LEADER COMMANDS

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

" Run Black and import sorter when saving py files
let g:black_linelength = 120
autocmd BufWritePre *.py execute ':Black'
autocmd BufWritePre *.py execute ':Isort'

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Use lua highlighting for pico8 cartridges
au BufNewFile,BufRead *.p8 set filetype=lua

" PLUGIN STUFF

" Bbye
" Close buffers quickly
nnoremap <C-x> :Bdelete<CR>

" Coc
" Manually fix every god damned thing with :Format
command! -nargs=0 Format :call CocAction('format')
nnoremap <leader>f :Format<CR>
nmap <silent> <C-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <C-j> <Plug>(coc-diagnostic-next)

" Find symbol of current document
nnoremap <silent> <leader>o  :<C-u>CocList outline<cr>
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>

" Airline
" use tabline all the time
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'jsformatter'
" remove the rightmost filetype info / line number etc.
let g:airline_section_x = ''
let g:airline_section_y = ''
let g:airline_section_z = ''
" don't collapse so much
let g:airline_inactive_collapse=0
" use short modes
let g:airline_mode_map = {
    \ '__'     : '-',
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'ic'     : 'I',
    \ 'ix'     : 'I',
    \ 'n'      : 'N',
    \ 'multi'  : 'M',
    \ 'ni'     : 'N',
    \ 'no'     : 'N',
    \ 'R'      : 'R',
    \ 'Rv'     : 'R',
    \ 's'      : 'S',
    \ 'S'      : 'S',
    \ 't'      : 'T',
    \ 'v'      : 'V',
    \ 'V'      : 'V',
    \ }

" Deoplete
let g:deoplete#enable_at_startup = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" Clap 👏
" Fuzzy file search
nnoremap <C-P> :Clap files<CR>
" Fuzzy buffer search
nnoremap <C-B> :Clap buffers<CR>
" Yank list
nnoremap <C-Y> :Clap yanks<CR>
" Grep!
nnoremap <C-G> :Clap grep<CR>

" Open-Browser-Github
let g:openbrowser_github_always_used_branch = 'master'
nnoremap <leader>g :OpenGithubFile<CR>

" Localvimrc
" Stop asking me about local vimrc
let g:localvimrc_persistent = 2
