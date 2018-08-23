let PLUGINS_DIR = '$HOME/.vim/plugins'

set nocompatible
call plug#begin(fnameescape(expand(PLUGINS_DIR)))

" Color Schemes
" https://github.com/morhetz/gruvbox/wiki/Installation
Plug 'morhetz/gruvbox'

" https://github.com/junegunn/seoul256.vim
Plug 'junegunn/seoul256.vim'

" Plug 'VundleVim/Vundle.vim'
Plug 'scrooloose/nerdtree'
Plug 'JamshedVesuna/vim-markdown-preview'
Plug 'junegunn/goyo.vim'
Plug 'airblade/vim-gitgutter'
Plug 'wakatime/vim-wakatime'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-commentary'

" Languages {

    Plug 'pangloss/vim-javascript'
    Plug 'tpope/vim-markdown'
    Plug 'python-mode/python-mode'

    " HTML + CSS
    Plug 'hail2u/vim-css3-syntax'
    Plug 'othree/html5.vim'
" }

" Editing
Plug 'Raimondi/delimitMate'
Plug 'kien/rainbow_parentheses.vim'
Plug 'ntpeters/vim-better-whitespace'

call plug#end()


" #############################################
" ############### CONFIGURATION ###############
" #############################################

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

set background=dark
colorscheme gruvbox

" Show hidden files in NERDTree by default
let NERDTreeShowHidden=1

let g:goyo_width = 100

" Airline configuration
let g:airline_theme='wombat'
let g:airline_powerline_fonts = 1
" let g:airline#extensions#branch#enabled = 1
" let g:airline#extensions#syntastic#enabled = 1
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#taboo#enabled = 1
" let g:airline#extensions#tagbar#enabled = 1
" let g:airline#extensions#whitespace#enabled = 1
" let g:airline#extensions#whitespace#mixed_indent_algo = 0
" let g:airline_left_sep=''
" let g:airline_powerline_fonts = 0
" let g:airline_right_sep=''

" ### Markdown Preview configuration ###
" Use GitHub flavoured markdown
let vim_markdown_preview_github=1
" Render images
let vim_markdown_preview_toggle=1"

" Strip all trailing whitespace everytime a file is saved,
" applies to all file types
autocmd BufEnter * EnableStripWhitespaceOnSave
