" Configuration for vim editor
"
" Most of this file is taken from the Vundle github readme:
" https://github.com/VundleVim/Vundle.vim

set nocompatible              " be iMproved, required
filetype off                  " required


" #####################################################
" ###################### PLUGINS ######################
" #####################################################

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" ### Colorschemes
" https://github.com/AlessandroYorba/Despacio
Plugin 'alessandroyorba/despacio'

" https://github.com/junegunn/seoul256.vim
Plugin 'junegunn/seoul256.vim'


" Vastly improve Javascript indentation and syntax support
Plugin 'pangloss/vim-javascript'

" Make parentheses into rainbows when nesting them
Plugin 'kien/rainbow_parentheses.vim'

" Status bar in bottom of vim
Plugin 'vim-airline/vim-airline'

" Preview markdown files in vim
Plugin 'JamshedVesuna/vim-markdown-preview'

" Plugin for distraction free writing
Plugin 'junegunn/goyo.vim'

" Comment out a line using `gcc`, `gc` for selection.
" https://github.com/tpope/vim-commentary
Plugin 'tpope/vim-commentary'

" Let vim handle syntax checks
" https://github.com/vim-syntastic/syntastic
" NOTE: Could not get it to work, let's try again later
" Plugin 'vim-syntastic/syntastic'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required


" #####################################################
" ################### CONFIGURATION ###################
" #####################################################

" Set colorscheme. There's a few colorschemes
" that look good available, easy to switch.
colorscheme despacio

" seoul256 (dark):
" "   Range:   233 (darkest) ~ 239 (lightest)
" "   Default: 237
"let g:seoul256_background = 236
"colo seoul256


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

" ### Markdown Preview configuration ###
" Use GitHub flavoured markdown
let vim_markdown_preview_github=1
" Render images
let vim_markdown_preview_toggle=1

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
" Show vertical line at 80 characters
set colorcolumn=80

" Automatic commands. Not sure what these do.
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

