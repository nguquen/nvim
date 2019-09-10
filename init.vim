" plugins
call plug#begin('~/.config/nvim/plugged')
"colorschemes
Plug 'rakr/vim-one'

"airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"navigation
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'easymotion/vim-easymotion'
Plug 'christoomey/vim-tmux-navigator'

"javascript
Plug 'pangloss/vim-javascript'
Plug 'crusoexia/vim-javascript-lib'
Plug 'mxw/vim-jsx'
Plug 'moll/vim-node'
Plug 'nikvdp/ejs-syntax'

"typescript
Plug 'ianks/vim-tsx'
Plug 'leafgarland/typescript-vim'

"graphql
Plug 'jparise/vim-graphql'

"ruby
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-haml'
Plug 'tpope/vim-bundler'
Plug 'kana/vim-textobj-user'
Plug 'nelstrom/vim-textobj-rubyblock'
Plug 'tpope/vim-endwise'
Plug 'thoughtbot/vim-rspec'
Plug 'skywind3000/asyncrun.vim'

"golang
Plug 'fatih/vim-go'
Plug 'jodosha/vim-godebug'

"protobuf
Plug 'uarun/vim-protobuf'

"swift
Plug 'bumaociyuan/vim-swift'

"smali
Plug 'kelwin/vim-smali'

"terraform
Plug 'hashivim/vim-terraform'

"monitoring
Plug 'wakatime/vim-wakatime'

"editor
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'honza/vim-snippets'
Plug 'w0rp/ale'
Plug 'nguquen/vim-shot-f'
Plug 'terryma/vim-multiple-cursors'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
Plug 'Raimondi/delimitMate'
Plug 'mbbill/undotree'
Plug 'majutsushi/tagbar'
Plug 'ludovicchabant/vim-gutentags'
"Plug 'chaoren/vim-wordmotion'
call plug#end()

" clipboard settings
set clipboard+=unnamedplus
set pastetoggle=<F2>

" color settings
set termguicolors
set background=dark
silent! colorscheme one
"change VertSpit color of colorscheme `one`
hi VertSplit guifg=#1b1b24 guibg=#707070 guisp=#707070 gui=bold

" airline settings
let g:airline_powerline_fonts=1
let g:airline_theme='base16_ocean'
let g:airline#extensions#tmuxline#enabled = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline_exclude_preview = 1
let g:airline#extensions#tabline#buffer_nr_show = 1

" editor settings
set updatetime=100 "for gitgutter
set number
set relativenumber
set visualbell
hi MatchParen guifg=#f43753 ctermfg=203 guibg=NONE ctermbg=NONE gui=bold cterm=bold
set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:·
set list
set tabstop=2 shiftwidth=2 expandtab
"let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
set guicursor=n-v-c:block-Cursor/lCursor-blinkon0,i-ci:ver25-Cursor/lCursor,r-cr:hor20-Cursor/lCursor
"disable automatic comment insertion
au FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
"let alt 'send' ESC key
let s:printable_ascii = map(range(65, 122), 'nr2char(v:val)')
for s:char in s:printable_ascii
  execute "inoremap <A-" . s:char . "> <Esc>" . s:char
endfor
unlet s:printable_ascii s:char
"highlight cursor line
"set cursorline
set splitbelow
set splitright
"set leader key
let mapleader=" "
"disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
inoremap <Up> <NOP>
inoremap <Down> <NOP>
inoremap <Left> <NOP>
inoremap <Right> <NOP>
"bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>
"bind // for search visual selection
"vnoremap // y/<C-R>"<CR>
"toggle
function! GetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction

function! ToggleList(bufname, pfx)
  let buflist = GetBufferList()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
    echohl ErrorMsg
    echo "Location List is Empty."
    return
  endif
  let winnr = winnr()
  exec(a:pfx.'open')
  if winnr() != winnr
    wincmd p
  endif
endfunction

nnoremap <silent> <Leader>[ :call ToggleList("Location List", 'l')<CR>
nnoremap <silent> <Leader>] :call ToggleList("Quickfix List", 'c')<CR>
"mapping misc keys
let g:gitgutter_map_keys = 0
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <Leader>q :q<CR>
nnoremap <silent> <Leader>x :x<CR>
noremap <silent> <Leader>h <C-W><C-H>
noremap <silent> <Leader>j <C-W><C-J>
noremap <silent> <Leader>k <C-W><C-K>
noremap <silent> <Leader>l <C-W><C-L>
noremap <silent> <leader>u :UndotreeToggle<CR>
noremap <silent> <Leader>re :reg<CR>
noremap <silent> <Leader>p "0p
noremap <silent> <Leader>y :let @0=@*<CR>
noremap <silent> <Leader>ch :noh<CR>
noremap <silent> <Leader>tt :tabnew<CR>
"mapping for quick switch windows
let g:airline_section_c = '%{winnr()}  %<%f%m %#__accent_red#%{airline#util#wrap(airline#parts#readonly(),0)}%#__restore__#'
for i in range(1, 9)
  execute 'nnoremap <silent> <Leader>' . i . ' :' . i . 'wincmd w<CR>'
endfor
"Toggle number display
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
  else
    set relativenumber
  endif
endfunc
nnoremap <silent> <Leader>nt :call NumberToggle()<cr>

" javascript settings
let g:jsx_ext_required = 0
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1
let g:javascript_plugin_flow = 1

" NERDTree settings
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
map <C-n> :NERDTreeToggle<CR>

" The Silver Searcher settings
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s --hidden -l --nocolor -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
  let g:ctrlp_show_hidden = 1
endif

" ale settings
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '⚠'
let g:ale_sign_info = 'ℹ'
let g:airline#extensions#ale#enabled = 1
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_linters = {
\  'javascript': ['flow', 'eslint'],
\  'java': [],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier', 'eslint'],
\   'typescript': ['prettier'],
\}
let g:ale_fix_on_save = 1
set signcolumn=yes

" easymotion settings
let g:EasyMotion_do_mapping = 0 "Disable default mappings
let g:EasyMotion_startofline = 0 "keep cursor column when JK motion
let g:EasyMotion_smartcase = 1
map <Leader>f <Plug>(easymotion-bd-w)
nmap <Leader>s <Plug>(easymotion-overwin-f2)
map <Leader>/ <Plug>(easymotion-sn)
map <Leader>n <Plug>(easymotion-next)
map <Leader>N <Plug>(easymotion-prev)

" multiple-cursors settings
let g:multi_cursor_use_default_mapping = 0
let g:multi_cursor_exit_from_insert_mode = 0
let g:multi_cursor_next_key='<C-s>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

" nerdcommenter settings
let NERDSpaceDelims=1

" tagbar settings
nnoremap <silent> <Leader>tb :TagbarToggle<CR>

" gutentags settings
set statusline+=%{gutentags#statusline('[Generating...]')}
let g:gutentags_add_default_project_roots=0
let g:gutentags_project_root = ['.withtags']
let g:gutentags_ctags_exclude=["node_modules"]

" RSpec.vim settings
map <silent> <Leader>sc :call RunCurrentSpecFile()<cr>:copen<cr>
map <silent> <Leader>sn :call RunNearestSpec()<cr>
map <silent> <Leader>sl :call RunLastSpec()<cr>
map <silent> <Leader>sa :call RunAllSpecs()<cr>
let g:rspec_command = "AsyncRun rspec {spec}"

" delimitMate settings
let g:endwise_no_mappings = 1
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1

"golang settings
let g:go_fmt_command = "goimports"
let g:go_autodetect_gopath = 1
au FileType go let $GOPATH = go#path#Detect()
let g:go_doc_keywordprg_enabled = 0

" coc.nvim
let g:coc_global_extensions = ['coc-css', 'coc-highlight', 'coc-html', 'coc-java', 'coc-json', 'coc-lists', 'coc-snippets', 'coc-tsserver', 'coc-yaml']
set hidden
"use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? coc#_select_confirm() :
      \ coc#expandableOrJumpable() ? coc#rpc#request('doKeymap', ['snippets-expand-jump','']) :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
let g:coc_snippet_next = '<tab>'
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <silent><expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
imap <silent><expr><CR> pumvisible() ? "\<C-y>" : "\<Plug>delimitMateCR\<Plug>DiscretionaryEnd"
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
autocmd FileType css,scss setlocal iskeyword=@,48-57,_,-,?,!,192-255
autocmd FileType json syntax match Comment +\/\/.\+$+
"integrate with airline
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'
"don't give |ins-completion-menu| messages.
set shortmess+=c
"Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)
"Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
"Use K to show documentation in preview window
"nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
"Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)
