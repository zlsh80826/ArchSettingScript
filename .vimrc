set nocompatible
set nu
set ruler
set showcmd
set showmatch
set ignorecase
set smartcase
set incsearch
set autowrite
set hidden
set tabstop=4
set shiftwidth=4
set expandtab
set encoding=utf-8
syntax on
set background=dark
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

autocmd FileType make set noexpandtab shiftwidth=4 softtabstop=0
