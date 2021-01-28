call plug#begin('~/.vim/plugged')

Plug 'liuchengxu/vim-which-key'
Plug 'easymotion/vim-easymotion'
Plug 'terryma/vim-multiple-cursors'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()


" space key as Leader
let mapleader = "\<Space>"


" === which-key config ===

nnoremap <silent> <leader> :WhichKey '<Space>'<CR>


" === completion config ===

" refresh completion
inoremap <silent><expr> <c-Space> coc#refresh()
" Tab to trigger completion / next item
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
" Shift+Tab to previous item 
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" i will eventually try to understand what this does
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" === EasyMotion config ===

map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

map  <Leader>s <Plug>(easymotion-sn)
omap <Leader>s <Plug>(easymotion-tn)

nmap <Leader>l <Plug>(easymotion-lineforward)
nmap <Leader>j <Plug>(easymotion-j)
nmap <Leader>k <Plug>(easymotion-k)
nmap <Leader>h <Plug>(easymotion-linebackward)

let g:EasyMotion_startofline = 0 " keep cursor column when JK motion


" === misc ===

" line numbers
set number

" indentation config
set expandtab
set tabstop=4
set shiftwidth=4
