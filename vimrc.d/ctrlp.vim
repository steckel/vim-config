" ctrlp.vim configuration
" ==============================================================================
let g:ctrlp_custom_ignore = { 'dir': '\.git$\|node_modules' }

nnoremap <leader>t :CtrlP<CR>
nnoremap <leader>T :CtrlPClearCache<CR>:CtrlP<CR>
nnoremap <leader>b :CtrlPBuffer<CR>
