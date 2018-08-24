let PLUGINS_FILE = '$HOME/.vim/vim-plug.vim'

set nocompatible
filetype off

" Leave hidden buffers open
set hidden
" By default Vim saves your last 8 commands, we can handle more
set history=100
" Enable mouse cursor
set mouse=a
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
set esckeys
" Set number of undo levels
set undolevels=200
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Set mapleader key
let mapleader=","
let maplocalleader=","
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
  set undodir=~/.vim/undo
endif
" Don’t create backups when editing files in certain directories
set backupskip=/tmp/*,/private/tmp/*
" Respect modeline in files
set modeline
set modelines=4
" Disable unsafe commands in .vimrc files
set secure
" Enable line numbers
set number
" Enable syntax highlighting
syntax on
" Highlight current line
set cursorline
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch
" Always show status line
set laststatus=2
" Disable error bells
set noerrorbells
" Don’t reset cursor to start of line when moving around.
set nostartofline
" Show the cursor position
set ruler
" Don’t show the intro message when starting Vim
set shortmess=atI
" Show the current mode
set showmode
" Show the filename in the window titlebar
set title
" Show the (partial) command as it’s being typed
set showcmd
" Show vertical line at 80 characters
set colorcolumn=80
" Disable sounds
set visualbell
" Set spell checking language to English
set spelllang=en

" Load Plugins
if filereadable(expand(PLUGINS_FILE))
  " Just doing `source` doesn't work
  execute 'source' fnameescape(PLUGINS_FILE)
else
  echom "Unable to find plugins dir"
endif

" ####################################################
" ################# KEY BINDINGS #####################
" ####################################################
nnoremap <leader>g :Goyo<cr>
nnoremap <leader>n :NERDTreeToggle<cr>
" Exit visual mode and save file with `jk`
inoremap jk <esc><esc>:w<cr>
" Toggle spelling
nnoremap <leader>s :set spell!<cr>
" Toggle comment on single line
nnoremap <leader>i :Commentary<cr>
" never go into Ex mode
noremap Q <NOP>
" Clear highlighted search results
nnoremap <leader>c :nohlsearch<cr>

" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Indentation
set autoindent
set smartindent
set smarttab
set tabstop=2
set expandtab
set shiftwidth=2
set softtabstop=2

filetype plugin indent on

" Force syntax
autocmd BufNewFile,BufRead *.html.twig  set syntax=html
autocmd BufNewFile,BufRead *.js         set syntax=javascript
autocmd BufNewFile,BufRead *.py         set syntax=python
autocmd BufNewFile,BufRead *.md         set filetype=markdown
autocmd BufNewFile,BufRead *.json       setfiletype json syntax=javascript

" Format .json files when opening them
autocmd FileType json :% ! jq .

