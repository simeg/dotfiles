set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'alessandroyorba/despacio'
Plugin 'pangloss/vim-javascript'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'JamshedVesuna/vim-markdown-preview'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Airline configuration
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#taboo#enabled = 1
let g:airline#extensions#tagbar#enabled = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 0
let g:airline_left_sep=''
let g:airline_powerline_fonts = 0
let g:airline_right_sep=''

" Markdown Preview configuration
let vim_markdown_preview_github=1 " Use GitHub flavoured markdown
let vim_markdown_preview_toggle=1 " Render images

" Leave hidden buffers open
set hidden
" By default Vim saves your last 8 commands, we can handle more
set history=100 " by default Vim saves your last 8 commands. We can handle more
" Enable mouse cursor
set mouse=a

colorscheme despacio

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
" Change mapleader
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
" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
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

" Automatic commands
if has("autocmd")
  " Enable file type detection
    filetype on
  " Treat .json files as .js
    autocmd BufNewFile,BufRead *.json setfiletype json syntax=javascript
  " Treat .md files as Markdown
    autocmd BufNewFile,BufRead *.md setlocal filetype=markdown

    au VimEnter * RainbowParenthesesActivate
    au Syntax * RainbowParenthesesLoadRound
    au Syntax * RainbowParenthesesLoadSquare
    au Syntax * RainbowParenthesesLoadBraces
endif

