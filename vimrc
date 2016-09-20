""""" 0) Key Mappings {{{
"""" 1) Leader {{{
set nocompatible
let mapleader=","
let g:mapleader=","
noremap \ ,
"""" END Leader }}}

"""" 2) Custom Mappings {{{
""" <leader>o {{{
map <leader>o :tabedit <C-R>=fnameescape(expand("%:h"))<CR>/
""" }}}
""" <leader>gd {{{
"" display all lines with keyword under cursor, and ask which one to jump to
nmap <leader>gd [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
" nmap <leader>gd [I:
""" }}}
""" <leader>b | <leader>sb {{{
nnoremap <leader>b :buffers!<CR>:b<Space>
nnoremap <leader>sb :buffers!<CR>:sb<Space>
""" }}}
""" [b | ]b | [B | ]B {{{
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>
""" }}}
""" [q | ]q {{{
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>
""" }}}
""" [l | ]l {{{
nnoremap <silent> [l :lprevious<CR>
nnoremap <silent> ]l :lnext<CR>
""" }}}
""" :DiffOrig {{{
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif
""" }}}
""" t | <leader>n | <leader>m (for Tagbar, NERDTree) {{{
""" }}}
"""" END Custom Mappings }}}
""""" END Key Mappings }}}

""""" I) Basic Configuration {{{
"""" 1) Reading {{{
colorscheme desert
set background=dark
set wrap
set showcmd
"" do not insert two spaces after punctuation on a join (J)
set nojoinspaces

"" gj & gk: treat long lines as break lines
" map j gj

"" spell checking for current buffer
" setlocal spell!

" :lcd %:h

"" auto reload vimrc
" autocmd! bufwritepost .vimrc source ~/.vimrc

""" jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \     exe "normal! g`\"" |
      \ endif
endif

""" Window Resize {{{
" map - <C-W>-
" map + <C-W>+
" map > <C-W>>
" map < <C-W><
""" END Window Resize }}}

""" Status Line {{{
set laststatus=2
set statusline=\ %{HasPaste()}%<%(%f%)%m%r%h\ %w
set statusline+=\ \ %<%(%{CurDir()}%)
set statusline+=\ \ \ \ \ \ [%{&ff}/%Y] 
set statusline+=%=%-10.(%l,%c%V%)\ \ \ %p%%/%L
hi StatusLine ctermfg=gray ctermbg=black
hi StatusLineNC ctermfg=darkblue ctermbg=gray
""" END Status Line }}}

""" Command Line wildmenu
" set wildmenu
" set wildignore=*.o,*.pyc
"" NOTICE: <C-d> should be enough
" set wildmode=list:longest,full
"""" END Reading }}}

"""" 2) Searching {{{
set ignorecase
set smartcase
set incsearch
"" :nohlsearch to disable highlight temporarily
set hlsearch
"" for regexp
set magic
"""" END Searching }}}

"""" 3) Editing {{{
set backspace=2

" highlight TrailingWhitespace ctermbg=red guibg=red
" match TrailingWhitespace /\s\+$/
" highlight LineOverFlow ctermbg=red guibg=red ctermfg=white
" match LineOverFlow /\%81v.\+/

""" Encoding {{{
"" Use Unix as the standard file type
" set fileformats=unix,dos,mac
" set encoding=cp936
" set termencoding=cp936
set fileencoding=gbk
set fileencodings=gbk,utf-8
""" }}}

""" Normally, we do not keep backup files
set nobackup
" set backup
" set backupdir=~/.vim/backup/
" set noswapfile

"" useful for `:*do` commands
" set hidden
""" Tabs {{{
"""   NOTICE: `gt` / `gT` should be enough
" let g:lasttab=1
" au TabLeave * let g:lasttab=tabpagenr()
" map <leader>1 :tabonly<CR>
" map <leader>m :tabmove<CR>
" nmap <leader>l :exe "tabn ". g:lasttab<CR>
""" }}}

"" auto reload when file changed
" set ar
"""" END Editing }}}
""""" END Basic Configuration }}}

""""" II) Programming {{{
"" filetype detection
filetype on
""" filetype-specific indenting
filetype indent on
filetype plugin on

""" syntax highlight
syntax on
set showmatch
set showmode

set autoindent
set smartindent

""" Tab key
" set expandtab
"" <BS> will delete a "sw" worth of space at the start of the line
set smarttab
set tabstop=4
set softtabstop=4
set shiftwidth=4

""" Folding
set foldenable
set foldmethod=marker
set foldlevel=0
set foldcolumn=0

"""" Programming Languages {{{
" nnoremap <leader>w :call TrimTrailingWhitespace()<CR>

""" C/C++ {{{
set tags=tags
autocmd FileType c,cc,cpp
    \ setlocal cindent expandtab |
    \ let &path .= "/usr/include,/usr/local/include," |
    \ setlocal colorcolumn=80 | highlight ColorColumn ctermbg=darkgray |
    \ setlocal wildignore=*.o,*.a,*.so
autocmd FileType c setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType cc,cpp setlocal shiftwidth=2 tabstop=4 softtabstop=4
autocmd BufNewFile,BufRead *.h,*.hpp map <leader>g :call IncludeGuard()<CR>
" autocmd FileType cc,cpp setlocal tags+=~/.vim/tags/cpptags
""" }}} 

""" Python {{{
autocmd FileType python setlocal expandtab shiftwidth=4 tabstop=8 sts=4
"" Round indent to multiple of 'shiftwidth', applies to '>' and '<'
autocmd FileType python setlocal shiftround
"" `vim-indent-guides` does not work on vim 7.2, try `n<<` or `n>>`
autocmd FileType python setlocal foldmethod=indent foldlevel=99
"" pydoc: <leader>pw
let g:pydoc_open_cmd = 'vsplit'
""" }}}

""" PHP {{{
autocmd FileType php setlocal cindent expandtab sw=4 ts=8 softtabstop=4
autocmd FileType php setlocal makeprg=php\ -l\ %
autocmd FileType php setlocal errorformat=%m\ in\ %f\ on\ line\ %l
autocmd FileType php setlocal omnifunc=phpcomplete#CompletePHP
""" }}}

""" Javascript, etc {{{
autocmd FileType javascript setlocal cindent expandtab sw=2 ts=8 sts=4
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
""" }}}

""" HTML {{{
runtime macros/matchit.vim
autocmd FileType html,xhtml setlocal expandtab shiftwidth=2 tabstop=2 sts=2
autocmd FileType html setlocal omnifunc=htmlcomplete#CompleteTags

autocmd FileType css setlocal expandtab sw=2 tabstop=4 softtabstop=4
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
""" }}}
"""" END Programming Languages }}}
""""" END Programming }}}

""""" III) Plugins {{{
"""" 1) Tagbar {{{
nmap t :TagbarToggle<CR>
"" default to be right
let g:tagbar_left = 1
let g:tagbar_autofocus = 1
let g:tagbar_width = 30
"""" END Tagbar }}}

"""" 2) NERDTree {{{
nnoremap <leader>n :NERDTreeFind<CR>
nnoremap <leader>m :NERDTreeToggle<CR>
let g:NERDTreeWinPos = "right"  " default to be left
" let NERDTreeShowBookmarks = 1
" let NERDTreeShowHidden = 1
" let NERDTreeKeepTreeInNewTab = 1
let NERDTreeIgnore = ['\.py[cd]$', '\~$', '\.swo$', '\.swp$']
let g:NERDTreeDirArrows = 0
""" Close vim if the only window left open is the NERDTree
autocmd bufenter *
    \ if (winnr("$") == 1 && exists("b:NERDTreeType") &&
    \   b:NERDTreeType == "primary") |
    \     q |
    \ endif
"""" END NERDTree }}}
""""" END Plugins }}}

""""" IV) Utility Functions {{{
""" HasPaste() {{{
fun! HasPaste()
    if &paste
        return '[PASTE]'
    else
        return ''
    endif
endfun
fun! CurDir()
    let curdir = substitute(getcwd(), $HOME, "~", "")
    return curdir
endfun
""" }}}
""" IncludeGuard() {{{
fun! IncludeGuard()
    let basename = substitute(bufname(""), '/', '_', 'g')
    let guard = substitute(toupper(basename), '\.', '_', "H"). '_'
    call append(0, "#ifndef " . guard)
    call append(1, "#define " . guard)
    call append(line("$"), "#endif  // " . guard)
endfun
""" }}}
""" TrimTrailingWhitespace() {{{
fun! TrimTrailingWhitespace()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//g
    call cursor(l, c)
endfun
""" }}}
""""" END Utility Functions }}}

""""" V) Miscellaneous {{{
" set relativenumber
""""" END Miscellaneous }}}
