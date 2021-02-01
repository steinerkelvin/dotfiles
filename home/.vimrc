call plug#begin('~/.vim/plugged')

Plug 'liuchengxu/vim-which-key'
Plug 'easymotion/vim-easymotion'
Plug 'terryma/vim-multiple-cursors'

call plug#end()


let mapleader = "\<Space>"

nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)

let g:EasyMotion_startofline = 0 " keep cursor column when JK motion

set expandtab
set tabstop=4
set shiftwidth=4
