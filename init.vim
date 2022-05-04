" plugins
call plug#begin('~/.config/nvim/plugged')
"colorschemes
Plug 'rakr/vim-one'

"airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"navigation
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'easymotion/vim-easymotion'
Plug 'christoomey/vim-tmux-navigator'

"javascript
Plug 'yuezk/vim-js'
Plug 'leafgarland/typescript-vim'
Plug 'moll/vim-node'
Plug 'nikvdp/ejs-syntax'
Plug 'maxmellon/vim-jsx-pretty'

"css in js
Plug 'nguquen/vim-styled-components', { 'branch': 'main' }
Plug 'alampros/vim-styled-jsx'

"graphql
Plug 'jparise/vim-graphql'
Plug 'pantharshit00/vim-prisma'

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
Plug 'towolf/vim-helm'

"protobuf
Plug 'uarun/vim-protobuf'

"swift
Plug 'bumaociyuan/vim-swift'

"smali
Plug 'kelwin/vim-smali'

"pine
Plug 'jbmorgado/vim-pine-script'

"dart
Plug 'dart-lang/dart-vim-plugin'

"terraform
Plug 'hashivim/vim-terraform'

"toml
Plug 'cespare/vim-toml', { 'branch': 'main' }

"monitoring
Plug 'wakatime/vim-wakatime'

Plug 'tpope/vim-dotenv'

"database
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'

Plug 'tomlion/vim-solidity'

"editor
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'xabikos/vscode-react'
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
Plug 'mattn/emmet-vim'
"Plug 'chaoren/vim-wordmotion'
Plug 'ryanoasis/vim-devicons'
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
" nnoremap K :grep! "\b<C-R><C-W>\b"<CR>

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
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1
let g:javascript_plugin_flow = 1

" NERDTree settings
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
let NERDTreeAutoDeleteBuffer=1
"open NERDTree automatically when vim starts up on opening a directory
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"NerdTreeToggleAndFind
function NerdTreeToggleAndFind()
    if &filetype == 'nerdtree' || exists("g:NERDTree") && g:NERDTree.IsOpen() || bufname('%') == ''
        :NERDTreeToggle
    else
        let l:pathStr = expand('%:p')
        try
            let l:pathStr = g:NERDTreePath.Resolve(l:pathStr)
            let l:pathObj = g:NERDTreePath.New(l:pathStr)
            let l:cwd = g:NERDTreePath.New(getcwd())
            if l:pathObj.isUnder(l:cwd)
              :NERDTreeFind
            else
              :NERDTreeToggle
            endif
        catch /^NERDTree.InvalidArgumentsError/
            call nerdtree#echoWarning('invalid path')
            return
        endtry
    endif
endfunction
nnoremap <silent> <C-n> :call NerdTreeToggleAndFind()<CR>

" grepprg settings
if executable('rg')
  " Use ag over grep
  set grepprg=rg\ --vimgrep\ --no-heading
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
\  'javascriptreact': ['flow', 'eslint'],
\  'typescript': ['eslint'],
\  'typescriptreact': ['eslint'],
\  'graphql': [],
\  'java': [],
\  'sql': ['sqlint'],
\  'python': ['flake8'],
\  'rust': [],
\  'go': [],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier', 'eslint'],
\   'javascriptreact': ['prettier', 'eslint'],
\   'typescript': ['prettier', 'eslint'],
\   'typescriptreact': ['prettier', 'eslint'],
\   'css': ['prettier'],
\   'json': ['prettier'],
\   'graphql': ['prettier'],
\   'html': ['prettier'],
\   'sql': ['pgformatter'],
\   'python': ['black'],
\   'rust': [],
\   'solidity': ['prettier'],
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
" let delimitMate_smart_matchpairs = '^\%(\w\|\!\|£\|\$\|_\|["''\[]\s*\S\)'
let delimitMate_smart_matchpairs = '^\%(\w\|\!\|[£$]\|_\|["''\[]\s*\S\|[^[:space:][:punct:]]\)'


"golang settings
let g:go_def_mapping_enabled = 0
let g:go_diagnostics_enabled = 0
let g:go_doc_keywordprg_enabled = 0
let g:go_metalinter_enabled = []
let g:go_code_completion_enabled = 0
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 0
let g:go_mod_fmt_autosave = 1
let g:go_auto_sameids = 0
let g:go_jump_to_error = 0

" coc.nvim
let g:coc_global_extensions = ['coc-css', 'coc-highlight', 'coc-html', 'coc-java', 'coc-json', 'coc-lists', 'coc-snippets', 'coc-tsserver', 'coc-yaml', 'coc-vimlsp', 'coc-svg', 'coc-emmet', 'coc-sh', 'coc-docker', 'coc-prisma', 'coc-db', 'coc-graphql', 'coc-python', 'coc-flutter', 'coc-rust-analyzer']
set hidden
"use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

imap <silent><expr> <TAB>
      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
      \ pumvisible() ? coc#_select_confirm() :
      \ emmet#isExpandable() ? "\<plug>(emmet-expand-abbr)" :
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
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
" grep from selected text
vnoremap <leader>g :<C-u>call <SID>GrepFromSelected(visualmode())<CR>
function! s:GrepFromSelected(type)
  let saved_unnamed_register = @@
  if a:type ==# 'v'
    normal! `<v`>y
  elseif a:type ==# 'char'
    normal! `[v`]y
  else
    return
  endif
  let word = substitute(@@, '\n$', '', 'g')
  let word = escape(word, '| ')
  let @@ = saved_unnamed_register
  execute 'CocList grep '.word
endfunction
"Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')
"Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)
" Using CocList
nnoremap <silent> <C-p> :<C-u>CocList files<cr>
nnoremap <silent> <Leader>g :<C-u>CocList grep<cr>
nnoremap <silent> <Leader>o :<C-u>CocList outline<cr>
nnoremap <silent> <Leader>b :<C-u>CocList buffers<cr>
nnoremap <silent> <Leader>[ :<C-u>CocList --normal locationlist<cr>
nnoremap <silent> <Leader>] :<C-u>CocList --normal quickfix<cr>
nnoremap <silent> <Leader>rl :<C-u>CocListResume<cr>
nnoremap <silent> <Leader>m :<C-u>CocList commands<cr>
nnoremap <silent> <Leader>d :<C-u>CocList diagnostics<cr>
" Change highlight colors for coc
hi CursorLine guibg=#4f5b66
hi CocHintSign ctermfg=59 guifg=#5c6370
hi CocRustTypeHint ctermfg=59 guifg=#5c6370
hi CocRustChainingHint ctermfg=59 guifg=#5c6370

"jsx highlight
autocmd BufNewFile,BufRead *.jsx set filetype=javascript.jsx
autocmd BufNewFile,BufRead *.tsx set filetype=typescript.tsx
highlight! def link jsxComponentName Identifier
highlight! def link jsVariableType Identifier
highlight! def link jsImport Identifier

"emmet
"let g:user_emmet_leader_key=','

"dbui
let g:db_ui_use_nerd_fonts=1
let g:db_ui_win_position='right'

"rust
au FileType rust let b:delimitMate_quotes = "\""
