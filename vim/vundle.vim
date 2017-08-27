set nocompatible
filetype off

function! InstallVundlePlugins ()
  :source ~/.vimrc
  :PluginInstall
endfunction

" Automatically run InstallVundlePlugins when this file is being opened
autocmd! BufWritePost vundle.vim :call InstallVundlePlugins()

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Color Schemes
" https://github.com/AlessandroYorba/Despacio
Plugin 'alessandroyorba/despacio'
" https://github.com/junegunn/seoul256.vim
Plugin 'junegunn/seoul256.vim'

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'JamshedVesuna/vim-markdown-preview'
Plugin 'junegunn/goyo.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'wakatime/vim-wakatime'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Comment out a line using `gcc`, `gc` for selection.
Plugin 'tpope/vim-commentary'

" Languages {

    Plugin 'pangloss/vim-javascript'
    Plugin 'tpope/vim-markdown'
    Plugin 'python-mode/python-mode'

    " HTML
    Plugin 'hail2u/vim-css3-syntax'
    Plugin 'othree/html5.vim'
" }

" Editing
Plugin 'Raimondi/delimitMate'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'ntpeters/vim-better-whitespace'

" All plugins must be added before the following line
call vundle#end()
filetype plugin indent on

" #############################################
" ############### CONFIGURATION ###############
" #############################################

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

colorscheme despacio

" seoul256 (dark):
"   Range:   233 (darkest) ~ 239 (lightest)
" "   Default: 237
"let g:seoul256_background = 236
"colo seoul256

" Open NERDTree if no file was specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Show hidden files in NERDTree by default
let NERDTreeShowHidden=1

let g:goyo_width = 100

" Airline configuration
let g:airline_theme='raven'
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
let vim_markdown_preview_toggle=1"

" Strip all trailing whitespace everytime a file is saved,
" applies to all file types
autocmd BufEnter * EnableStripWhitespaceOnSave
