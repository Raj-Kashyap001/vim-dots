" ============================================================================
" BASIC SETTINGS
" ============================================================================

set number
set relativenumber
set mouse=a

let g:netrw_liststyle = 3
let g:netrw_banner    = 0
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'
let g:netrw_hide      = 1


set ttimeout
set ttimeoutlen=10
set timeoutlen=300

" Cursor shape 
let &t_SI = "\e[6 q"   " insert: bar
let &t_SR = "\e[4 q"   " replace: underline
let &t_EI = "\e[2 q"   " normal: block

filetype plugin indent on
syntax on
set wildmenu
set autoindent
set expandtab
set backupcopy=yes
set softtabstop=2
set shiftwidth=2
set shiftround
set nowrap
set noshowmode
set clipboard^=unnamed,unnamedplus
set backspace=indent,eol,start
set hidden
set laststatus=2
set display=lastline
set showcmd
set incsearch
set hlsearch
set ttyfast
set lazyredraw
set splitbelow
set splitright
set cursorline
set cursorlineopt=number
set wrapscan
set report=0
set synmaxcol=200
set list

colorscheme github_dark 

if has('multi_byte') && &encoding ==# 'utf-8'
  let &listchars = 'tab:▸ ,extends:❯,precedes:❮,nbsp:±'
else
  let &listchars = 'tab:> ,extends:>,precedes:<,nbsp:.'
endif

" Fish shell compatibility
if &shell =~# 'fish$'
  set shell=/bin/bash
endif

" Omni function autocomplete
augroup omnifunc_setup
  autocmd!
  autocmd FileType * setlocal omnifunc=syntaxcomplete#Complete
augroup END
" ============================================================================
" LEADER KEY
" ============================================================================
let mapleader = " "

" ============================================================================
" TAB MANAGEMENT
" ============================================================================
" Create and close tabs
nnoremap <leader>tn :tabnew<Space>
nnoremap <leader>tc :tabclose<CR>

" Cycle through tabs
nnoremap <Tab> :tabnext<CR>
nnoremap <S-Tab> :tabprevious<CR>

" ============================================================================
" STATUSLINE
" ============================================================================
set statusline=
set statusline+=\%#StatusLineMode#\ %{StatuslineMode()}\ 
set statusline+=%#StatusLine#
set statusline+=\ %f                          " File path
set statusline+=\ %m                          " Modified flag
set statusline+=\ %r                          " Readonly flag
set statusline+=%=                            " Right align
set statusline+=\ %#StatusLineExtra#
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\ │\ %{&fileformat}
set statusline+=\ │\ %Y                       " File type
set statusline+=\ %#StatusLinePosition#
set statusline+=\ %p%%                        " Percentage
set statusline+=\ │\ %l:%c                    " Line:Column
set statusline+=\ 


" Status line colors (using terminal colors)
hi StatusLine cterm=NONE ctermfg=7 ctermbg=8
hi StatusLineMode cterm=bold ctermfg=0 ctermbg=2
hi StatusLineExtra cterm=NONE ctermfg=7 ctermbg=0
hi StatusLinePosition cterm=bold ctermfg=0 ctermbg=7
" Custom line number colors
hi LineNr ctermfg=240 ctermbg=NONE
hi CursorLineNr ctermfg=7 

function! StatuslineMode()
  let l:mode = mode()
  if l:mode ==# 'n'
    hi StatusLineMode cterm=bold ctermfg=0 ctermbg=2
    return 'NORMAL'
  elseif l:mode ==# 'i'
    hi StatusLineMode cterm=bold ctermfg=0 ctermbg=4
    return 'INSERT'
  elseif l:mode ==# 'v' || l:mode ==# 'V' || l:mode ==# "\<C-v>"
    hi StatusLineMode cterm=bold ctermfg=0 ctermbg=5
    return 'VISUAL'
  elseif l:mode ==# 'R'
    hi StatusLineMode cterm=bold ctermfg=0 ctermbg=1
    return 'REPLACE'
  elseif l:mode ==# 'c'
    hi StatusLineMode cterm=bold ctermfg=0 ctermbg=3
    return 'COMMAND'
  else
    return l:mode
  endif
endfunction







" ============================================================================
" NETRW BOTTOM SPLIT TOGGLE (Ctrl+b)
" ============================================================================
" Open files in new tab from netrw
" let g:netrw_browse_split = 3

function! ToggleNetrwBottom()
  if exists("t:netrw_bufnr") && bufwinnr(t:netrw_bufnr) != -1
    execute bufwinnr(t:netrw_bufnr) . "wincmd c"
  else
    botright 10split
    Explore
    let t:netrw_bufnr = bufnr("%")
  endif
endfunction

nnoremap <C-b> :call ToggleNetrwBottom()<CR>



" ============================================================================
" COMMENT TOGGLE (gc)
" ============================================================================

function! ToggleComment() range
  let cs = &commentstring
  if empty(cs) | let cs = '#%s' | endif
  
  " Parse commentstring safely
  let idx = stridx(cs, '%s')
  if idx == -1
    let left = cs
    let right = ''
  else
    let left = strpart(cs, 0, idx)
    let right = strpart(cs, idx + 2)
  endif
  
  " Trim whitespace
  let left = substitute(left, '^\s*\|\s*$', '', 'g')
  let right = substitute(right, '^\s*\|\s*$', '', 'g')
  
  " Force correct values for HTML
  if &filetype ==# 'html'
    let left  = '<!--'
    let right = '-->'
  endif
  
  for lnum in range(a:firstline, a:lastline)
    let line = getline(lnum)
    if line =~ '^\s*$' | continue | endif
    
    let indent  = matchstr(line, '^\s*')
    let content = substitute(line, '^\s*', '', '')
    
    " Escape special regex characters for detection
    let left_escaped = escape(left, '\\/.*$^~[]')
    
    " Check if line is commented
    if content =~# '^\V' . left_escaped
      " ================== UNCOMMENT ==================
      let new = substitute(content, '^\V' . escape(left, '\') . '\v\s*', '', '')
      
      " Remove ending marker if present
      if !empty(right)
        let right_escaped = escape(right, '\')
        let new = substitute(new, '\v\s*\V' . right_escaped . '\v\s*$', '', '')
      endif
      
      let new = indent . new
    else
      " ================== COMMENT ==================
      let new = indent . left . ' ' . content
      if !empty(right)
        let new .= ' ' . right
      endif
    endif
    
    call setline(lnum, new)
  endfor
endfunction

nnoremap <silent> gc :call ToggleComment()<CR>
xnoremap <silent> gc :call ToggleComment()<CR>


" ============================================================================
" WINDOW NAVIGATION & RESIZING
" ============================================================================
nnoremap <C-M-h> <C-w>h
nnoremap <C-M-j> <C-w>j
nnoremap <C-M-k> <C-w>k
nnoremap <C-M-l> <C-w>l

nnoremap <M-H> :vertical resize -5<CR>
nnoremap <M-L> :vertical resize +5<CR>
nnoremap <M-J> :resize +2<CR>
nnoremap <M-K> :resize -3<CR>


" ============================================================================
" COMPLETION & BASIC AUTO-PAIRS
" ============================================================================
set completeopt=menuone,noinsert,noselect
inoremap <C-.> <C-x><C-o>

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"

" Basic auto-pairs
inoremap <expr> " getline('.')[col('.')-1] == '"' ? "\<Right>" : "\"\"\<Left>"
inoremap <expr> ' getline('.')[col('.')-1] == "'" ? "\<Right>" : "''\<Left>"
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap <expr> ) getline('.')[col('.')-1] == ')' ? "\<Right>" : ")"
inoremap <expr> ] getline('.')[col('.')-1] == ']' ? "\<Right>" : "]"
inoremap <expr> } getline('.')[col('.')-1] == '}' ? "\<Right>" : "}"

" Auto-pair with newline for braces
inoremap <expr> <CR> AutoPairCR()

function! AutoPairCR()
  let line = getline('.')
  let col = col('.') - 1
  if col > 0 && line[col-1] == '{' && line[col] == '}'
    return "\<CR>\<Esc>O"
  else
    return "\<CR>"
  endif
endfunction


" ============================================================================
" HTML/XML AUTO-CLOSE TAG
" ============================================================================
augroup autoclose_tags
  autocmd!
  autocmd FileType html,xml,svg,javascriptreact,typescriptreact inoremap <buffer> <expr> > CloseTagMid()
augroup END

function! CloseTagMid()
  let line = getline('.')
  let c = col('.') - 1
  let lt = strridx(line, '<', c)
  if lt == -1 | return '>' | endif
  if line[lt + 1] == '/' | return '>' | endif

  let tag = matchstr(line[lt+1 : c], '^[A-Za-z][A-Za-z0-9:-]*')
  if empty(tag) | return '>' | endif
  if line[:c] =~ '/\s*$' | return '>' | endif

  return '>' . '</' . tag . '>' . repeat("\<Left>", len(tag) + 3)
endfunction

" ============================================================================
" HTML5 BOILERPLATE  
" ============================================================================


function Html5()
    " Insert the HTML5 boilerplate
    let l:boilerplate = [
        \ '<!DOCTYPE html>',
        \ '<html lang="en">',
        \ '<head>',
        \ '    <meta charset="UTF-8">',
        \ '    <meta name="viewport" content="width=device-width, initial-scale=1.0">',
        \ '    <title></title>',
        \ '</head>',
        \ '<body>',
        \ '    ',
        \ '</body>',
        \ '</html>'
        \ ]

    " Get current line number
    let l:start_line = line('.')

    " Delete current line content
    normal! dd

    " Insert the boilerplate
    call append(l:start_line - 1, l:boilerplate)

    " Move cursor to title tag (between <title></title>)
    call cursor(l:start_line + 5, 12)

    " Enter insert mode
    startinsert
endfunction


" Define the command 
augroup html_commands
  autocmd!
  autocmd FileType html command! -buffer Html5 call Html5() 
augroup END


" Convert split window to tab
nnoremap <leader>st <C-w>T

" Convert tab back to splits
nnoremap <leader>sh <C-w>K

nnoremap <leader>sv <C-w>H

if has("gui_running")
  set guioptions-=T   "remove toolbar
  set guioptions-=L   "remove left scrollbar

  set guifont=JetBrainsMono\ Nerd\ Font\ 15
  " set guioptions-=m    "remove menu bar 

  syntax enable

  function! StatuslineMode()
  let l:mode = mode()

  if l:mode ==# 'n'
    hi StatusLineMode guifg=#0d1117 guibg=#2ea043 gui=bold
    return 'NORMAL'
  elseif l:mode ==# 'i'
    hi StatusLineMode guifg=#0d1117 guibg=#58a6ff gui=bold
    return 'INSERT'
  elseif l:mode ==# 'v' || l:mode ==# 'V' || l:mode ==# "\<C-v>"
    hi StatusLineMode guifg=#0d1117 guibg=#a371f7 gui=bold
    return 'VISUAL'
  elseif l:mode ==# 'R'
    hi StatusLineMode guifg=#0d1117 guibg=#f85149 gui=bold
    return 'REPLACE'
  elseif l:mode ==# 'c'
    hi StatusLineMode guifg=#0d1117 guibg=#d29922 gui=bold
    return 'COMMAND'
  else
    return l:mode
  endif
endfunction

hi StatusLine        guifg=#c9d1d9 guibg=#161b22 gui=NONE
hi StatusLineNC      guifg=#8b949e guibg=#0d1117 gui=NONE
hi VertSplit         guifg=#30363d guibg=#0d1117

hi StatusLineExtra   guifg=#8b949e guibg=#161b22
hi StatusLinePosition guifg=#c9d1d9 guibg=#161b22 gui=bold

hi LineNr        guifg=#6e7681 guibg=NONE
hi CursorLineNr guifg=#c9d1d9 guibg=NONE gui=bold

endif

" Set Transparent BG only on non gui mode
hi Normal guibg=NONE ctermbg=NONE


if has("gui_running")
  syntax enable
  set guioptions-=T   "remove toolbar
  set guioptions-=L   "remove left scrollbar

  set guifont=JetBrainsMono\ Nerd\ Font\ 15
  set guioptions-=m    "remove menu bar

  hi Normal guibg=#242424 ctermbg=NONE
endif


