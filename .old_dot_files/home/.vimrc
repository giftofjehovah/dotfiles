""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'joshdick/onedark.vim'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim'
Plug 'honza/vim-snippets'
Plug 'sirver/ultisnips'
Plug 'scrooloose/syntastic'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'scrooloose/nerdcommenter'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'maxmellon/vim-jsx-pretty'
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set backspace=2 " make backspace work normal
set ttimeoutlen=0 " same as MacVim; updates powerline immediately on Escape
set mouse=a " use mouse everywhere
set clipboard=unnamed " use system clipboard
set autoindent
set smartindent
set noshowmode
set lsp=0
set expandtab
set shiftwidth=2
set softtabstop=2
set nosmarttab
set autoread
set encoding=utf8

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim UI
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
colorscheme onedark
set relativenumber " Use relative line numbers
set number " turn on line numbers
syntax on " Enable syntax highlighting
set laststatus=2 " always show the status line
set signcolumn=yes

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" CtrlP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ctrlp_show_hidden= 1
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim Airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='onedark'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Syntastic
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_javascript_checkers = ['standard']
let g:syntastic_javascript_standard_generic = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Emmet
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:user_emmet_expandabbr_key = '<D-e>'
let g:user_emmet_settings = {
\  'javascript' : {
\      'extends' : 'jsx',
\      'quote_char': "'",
\  },
\}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader="\<Space>"

nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :bd<CR>
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l
nnoremap <Leader>d yyp

:noremap <left> :bp<CR>
:noremap <right> :bn<CR>

nmap <Leader>m :NERDTreeToggle<CR>
nmap <Leader>t :tabnew<CR>
nmap t o<ESC>
nmap T O<ESC>
nmap <c-p> :e <c-d>

vnoremap < <gv
vnoremap > >gv

" map alt j & k to move lines up and down, use 'sed -n l' in cli to find out
" special char
nnoremap ∆ :m .+1<CR>==
nnoremap ˚ :m .-2<CR>==
inoremap ∆ <Esc>:m .+1<CR>==gi
inoremap ˚ <Esc>:m .-2<CR>==gi
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

map <Leader>a ggVG
map <silent> <C-s> :NERDTree<CR><C-w>p:NERDTreeFind<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autocommands
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd FileType javascript UltiSnipsAddFiletypes javascript-standard
autocmd FileType javascript UltiSnipsAddFiletypes javascript-react
autocmd FileType javascript UltiSnipsAddFiletypes javascript-angular


au BufWritePost .vimrc so ~/.vimrc
au InsertEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger     . " <C-R>=g:UltiSnips_Complete()<cr>"
au InsertEnter * exec "inoremap <silent> " .     g:UltiSnipsJumpBackwardTrigger . " <C-R>=g:UltiSnips_Reverse()<cr>"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let NERDTreeDirArrowExpandable = '▷'
let NERDTreeDirArrowCollapsible = '▼'
let NERDTreeShowHidden=1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! g:UltiSnips_Complete()
  call UltiSnips#ExpandSnippet()
  if g:ulti_expand_res == 0
    if pumvisible()
      return "\<C-n>"
    else
      call UltiSnips#JumpForwards()
      if g:ulti_jump_forwards_res == 0
        return "\<TAB>"
      endif
    endif
  endif
  return ""
endfunction

function! g:UltiSnips_Reverse()
  call UltiSnips#JumpBackwards()
  if g:ulti_jump_backwards_res == 0
    return "\<C-P>"
  endif

  return ""
endfunction


if !exists("g:UltiSnipsJumpForwardTrigger")
  let g:UltiSnipsJumpForwardTrigger = "<tab>"
endif

if !exists("g:UltiSnipsJumpBackwardTrigger")
  let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
endif
