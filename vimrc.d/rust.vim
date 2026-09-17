" Rust configuration
" ==============================================================================
let g:rustfmt_autosave = 1
au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
" Rust omni-completion is unconfigured here on purpose: racer was archived
" upstream in 2021 and superseded by rust-analyzer. The vim-racer submodule
" has been removed along with its settings; wire up rust-analyzer through
" ALE when it is needed.
