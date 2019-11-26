let PLUGINS_FILE = '$HOME/.vim/vim-plug.vim'

set nocompatible
filetype off

set hidden                      " Leave hidden buffers open
set history=100                 " Command history cap
set undolevels=200
set mouse=a                     " Enable mouse cursor
set clipboard=unnamed           " Use the OS clipboard by default
set wildmenu                    " Enhance cli completion
set esckeys                     " Allow cursor keys in insert mode
set backspace=indent,eol,start  " Allow backspace in insert mode
set ttyfast
set encoding=utf-8 nobomb
set scrolloff=5                 " Keep N lines visible above/below the cursor

let mapleader=","
let maplocalleader=","

set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
  set undodir=~/.vim/undo
endif
"
" Skip backups editing files here
set backupskip=/tmp/*,/private/tmp/*
set modeline        " Respect modeline in files
set modelines=4
set secure          " Disable unsafe commands in .vimrc files
set number          " Enable line numbers
syntax on           " Enable syntax highlighting
set cursorline      " Highlight current line
set hlsearch        " Highlight searches
set ignorecase      " Ignore case of searches
set incsearch       " Highlight dynamically as pattern is typed
set laststatus=2    " Always show status line
set noerrorbells    " Disable error bells
set nostartofline   " Don’t reset cursor to start of line when moving around
set ruler           " Show the cursor position
set shortmess=atI   " Don’t show the intro message when starting Vim
set showmode        " Show the current mode
set title           " Show the filename in the window titlebar
set showcmd         " Show the (partial) command as it’s being typed
set colorcolumn=80  " Show vertical line at 80 characters
set visualbell      " Disable sounds
set spelllang=en    " Set spell checking language to English

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

