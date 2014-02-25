set nocompatible        " Use Vim settings, rather than Vi settings
set autoindent          " always set autoindenting on
set history=50          " keep 50 lines of command line history
set ignorecase          " Do case insensitive matching
set showmatch           " Show matching brackets.
set showcmd             " Show (partial) command in status line.
set smartcase           " Do smart case matching
set incsearch           " do Incremental searching
set noswapfile          " Do not use swapfile
set nobackup            " do not keep a backup file, use versions instead
set nowrap              " do not wraplines longer than the width of the window
set autowrite           " Automatically save before commands like:next and:make
set autoread            " automatically read changed files again.
set hidden              " Hide buffers when they are abandoned
set ruler               " show the cursor position all the time
set mousehide           " Hide the mouse when typing text
set wildmenu            " command-line completion in an enhanced mode
set cmdheight=2         " Make command line two lines high
set complete+=k         " scan the files given with the 'dictionary' option
set bs=indent,eol,start " allow backspacing over everything in insert mode
set wildignore=*.bak,*.o,*.e,*~,*.dat " wildmenu: ignore these extensions

set tabstop=4
set shiftwidth=4
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,default,latin1

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Change the working directory to the directory containing the current file
  autocmd BufEnter * :lchdir %:p:h
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  filetype plugin indent on
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!
  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
  autocmd BufRead,BufNewFile *.txt setlocal ft=txt
  autocmd FileType python setlocal foldmethod=indent
  autocmd FileType python setlocal et sta sw=4 sts=4
  " When editing a file, always jump to the last known cursor position.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
  augroup END
endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
                  \ | wincmd p | diffthis
endif

" Edit another file in the same directory as the current file
" uses expression to extract path from current file's path
map ,e :e <C-R>=expand("%:p:h") . "\/" <CR>
map ,r :r <C-R>=expand("%:p:h") . "\/" <CR>
map  <buffer>  <silent>  <F11>    <ESC>:Tlist<CR>
imap <buffer>  <silent>  <F11>    <ESC>:Tlist<CR>
map  <buffer>  <silent>  <C-F11>  <ESC>:TlistUpdate<CR>
imap <buffer>  <silent>  <C-F11>  <ESC>:TlistUpdate<CR>

"-------------------------------------------------------------------------------
"    F2   -  write file without confirmation
"    F3   -  call file explorer Ex
"    F4   -  show tag under curser in the preview window (tagfile must exist!)
"    F5   -  open quickfix error window
"    F6   -  close quickfix error window
"    F7   -  display previous error
"    F8   -  display next error   
"-------------------------------------------------------------------------------
map   <silent> <F2>        :write<CR>
map   <silent> <F3>        :Explore<CR>
nmap  <silent> <F4>        :exe ":ptag ".expand("<cword>")<CR>
map   <silent> <F5>        :copen<CR>
map   <silent> <F6>        :cclose<CR>
map   <silent> <F7>        :cp<CR>
map   <silent> <F8>        :cn<CR>
"
imap  <silent> <F2>   <Esc>:write<CR>
imap  <silent> <F3>   <Esc>:Explore<CR>
imap  <silent> <F4>   <Esc>:exe ":ptag ".expand("<cword>")<CR>
imap  <silent> <F5>   <Esc>:copen<CR>
imap  <silent> <F6>   <Esc>:cclose<CR>
imap  <silent> <F7>   <Esc>:cp<CR>
imap  <silent> <F8>   <Esc>:cn<CR>
"
"-------------------------------------------------------------------------------
" Fast switching between buffers
" The current buffer will be saved before switching to the next one.
" Choose :bprevious or :bnext
"-------------------------------------------------------------------------------
 map  <silent> <C-tab>  <Esc>:if &modifiable && !&readonly && 
     \                  &modified <CR> :write<CR> :endif<CR>:bprevious<CR>
imap  <silent> <C-tab>  <Esc>:if &modifiable && !&readonly && 
     \                  &modified <CR> :write<CR> :endif<CR>:bprevious<CR>
"
"-------------------------------------------------------------------------------
" Leave the editor with Ctrl-q : Write all changed buffers and exit Vim
"-------------------------------------------------------------------------------
nmap  <C-q>    :wqa<CR>
"-------------------------------------------------------------------------------
" autocomplete parenthesis, brackets and braces
"-------------------------------------------------------------------------------
"inoremap ( ()<Left>
"inoremap [ []<Left>
"inoremap { {}<Left>
"
"vnoremap ( s()<Esc>P<Right>%
"vnoremap [ s[]<Esc>P<Right>%
"vnoremap { s{}<Esc>P<Right>%

" Ctrl+F12 run java program and Python perl etc scripts
function! ProgRun(...)
	update
	let e = 0
	let ext = expand("%:e")
	if ext == "java" && getftime(expand("%:r") . ".class") < getftime(expand("%"))
		make
		let e = v:shell_error
	endif
	if e == 0
		if exists("g:runprogstring")
			execute "!" . g:runprogstring
		else
			let idx = 1
			let arg = ""
			while idx <= a:0
				execute "let a = a:" . idx
				let arg = arg . ' ' . a
				let idx = idx + 1
			endwhile
			cd %:p:h
			if ext == "java"
				execute "!java " . expand("%:r") . " " . arg
			elseif ext == "py"
				execute "!python " . expand("%") . " " . arg
			elseif ext == "pl"
				execute "!perl " . expand("%") . " " . arg
			elseif ext == "rb"
				execute "!ruby " . expand("%") . " " . arg
			elseif ext == "tcl"
				execute "!tclsh " . expand("%") . " " . arg
			elseif ext == "lisp"
				execute "!clisp " . expand("%") . " " . arg
			endif
			cd -
		endif
	endif
endfunction

command! -nargs=* Run call ProgRun(<f-args>)
set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
map   <C-F12>  <Esc>:Run<CR>
map   <F12>    <Esc>:make<CR>
imap  <C-F12>  <Esc>:Run<CR>
imap  <F12>    <Esc>:make<CR>
