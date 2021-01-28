" vim plug plugins
call plug#begin('~/.vim/plugged')

Plug 'liuchengxu/vim-which-key'
Plug 'easymotion/vim-easymotion'
Plug 'terryma/vim-multiple-cursors'
" completion framework
Plug 'neoclide/coc.nvim', {'branch': 'release'}


call plug#end()


" space key as Leader
let mapleader = "\<Space>"


" which-key config

nnoremap <silent> <leader> :WhichKey '<Space>'<CR>


" EasyMotion config

map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

map  <Leader>s <Plug>(easymotion-sn)
omap <Leader>s <Plug>(easymotion-tn)

nmap <Leader>l <Plug>(easymotion-lineforward)
nmap <Leader>j <Plug>(easymotion-j)
nmap <Leader>k <Plug>(easymotion-k)
nmap <Leader>h <Plug>(easymotion-linebackward)

let g:EasyMotion_startofline = 0 " keep cursor column when JK motion


" indentation config

set expandtab
set tabstop=4
set shiftwidth=4
