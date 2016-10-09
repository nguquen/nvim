" plugins
call plug#begin('~/.config/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
Plug 'rakr/vim-one'
Plug 'pangloss/vim-javascript'
Plug 'crusoexia/vim-javascript-lib'
Plug 'mxw/vim-jsx'
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-bundler'
Plug 'wakatime/vim-wakatime'
Plug 'airblade/vim-gitgutter'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'carlitux/deoplete-ternjs'
call plug#end()
" clipboard
set clipboard=unnamed
set pastetoggle=<F2>
" color
set termguicolors
set background=dark
colorscheme one
" airline
let g:airline_powerline_fonts=1
let g:airline_theme='one'
"let g:airline_theme='solarized'
"let g:airline_solarized_bg='dark'
"let g:solarized_termcolors=256
let g:airline#extensions#tmuxline#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline_exclude_preview = 1
" disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
" setting editors
set number
hi MatchParen guifg=#f43753 ctermfg=203 guibg=NONE ctermbg=NONE gui=bold cterm=bold
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·
set list
set tabstop=2 shiftwidth=2 expandtab
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
" let alt 'send' ESC key
let s:printable_ascii = map(range(32, 126), 'nr2char(v:val)')
call remove(s:printable_ascii, 92)
for s:char in s:printable_ascii
    execute "inoremap <A-" . s:char . "> <Esc>" . s:char
endfor
unlet s:printable_ascii s:char
" jsx
let g:jsx_ext_required = 0
" NERDTree
map <C-n> :NERDTreeToggle<CR>
" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif
" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
" Use deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1
let g:deoplete#file#enable_buffer_path = 1
inoremap <silent><expr><tab> pumvisible() ? "\<C-n>" : "\<tab>"
inoremap <silent><expr> j pumvisible() ? "\<C-n>" : "j"
inoremap <silent><expr> k pumvisible() ? "\<C-p>" : "k"
inoremap <silent><expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <silent><expr><Esc> pumvisible() ? "\<C-e>" : "\<Esc>"
inoremap <silent><expr><c-@> deoplete#mappings#manual_complete()
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

