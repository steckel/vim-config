" don't bother with vi compatibility
set nocompatible

syntax enable " enable syntax highlighting

" set autoindent
set autoread                                                 " reload files when changed on disk, i.e. via `git checkout`
set background=dark                                          " set theme to darkbackground (specifically for solarized dark)
set cursorcolumn                                             " highlight current column
set cursorline                                               " highlight current line
" Tmux & OSC 52 clipboard integration
" When running inside tmux, synchronize Vim's clipboard registers with tmux's
" buffer and propagate to the outer terminal clipboard via OSC 52 (-w flag).
if !empty($TMUX) && executable('tmux')
  if has('clipboard_provider')
    function! s:TmuxCopy(reg, type, lines) abort
      let l:text = join(a:lines, "\n")
      if a:type ==# 'V'
        let l:text .= "\n"
      endif
      call system('tmux load-buffer -w -', l:text)
    endfunction

    function! s:TmuxPaste(reg) abort
      let l:text = system('tmux show-buffer')
      if v:shell_error != 0 || empty(l:text)
        return ['v', []]
      endif
      let l:lines = split(l:text, "\n", 1)
      if len(l:lines) > 0 && l:lines[-1] ==# ''
        call remove(l:lines, -1)
        return ['V', l:lines]
      endif
      return ['v', l:lines]
    endfunction

    let v:clipproviders['tmux'] = {
          \ 'available': { -> 1 },
          \ 'copy': { '+': function('s:TmuxCopy'), '*': function('s:TmuxCopy') },
          \ 'paste': { '+': function('s:TmuxPaste'), '*': function('s:TmuxPaste') },
          \ }
    set clipmethod=tmux,wayland,x11
  elseif exists('##TextYankPost')
    augroup TmuxClipboardSync
      autocmd!
      autocmd TextYankPost *
            \ if index(['', '0', '+', '*'], v:event.regname) != -1 |
            \   call system('tmux load-buffer -w -', join(v:event.regcontents, "\n") . (v:event.regtype ==# 'V' ? "\n" : '')) |
            \ endif
    augroup END
  endif
endif

set clipboard=unnamed                                        " yank and paste with the system clipboard
                                                             " note: every yank lands on the OS clipboard,
                                                             " including on shared/managed machines
set directory-=.                                             " don't store swapfiles in the current directory
" set encoding=utf-8
set expandtab                                                " expand tabs to spaces
" set ignorecase                                               " case-insensitive search
" set incsearch                                                " search as you type
set laststatus=2                                             " always show statusline
set list                                                     " show trailing whitespace
set listchars=tab:▸\ ,trail:▫,eol:¬
" set ruler                                                    " show where you are
" set scrolloff=3                                              " show context above/below cursorline
" set showcmd
" set smartcase                                                " case-sensitive search if any caps
" set wildignore=node_modules/**,tmp/**
" set wildmenu                                                 " show a navigable menu for tab completion
" set wildmode=longest,list,full
set mouse=a                                                    " Enable basic mouse behavior such as resizing buffers and scrolling.
if has('mouse_sgr')
  set ttymouse=sgr                                             " SGR extended mouse mode for tmux and modern terminals
endif
set number                                                   " show line numbers
set shiftwidth=2                                             " normal mode indentation commands use 2 spaces
set softtabstop=2                                            " insert mode tab and backspace use 2 spaces
set tabstop=8                                                " actual tabs occupy 8 characters

" keyboard shortcuts
" -----------------------------------------------------------------------------------------------------------------------
let mapleader = ','
nnoremap <C-w>c :tabnew<CR>                                 " tab navigation
nnoremap <C-w>p :tabp<CR>
nnoremap <C-w>n :tabn<CR>
noremap <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

" go to end of previous word
noremap <S-E> gE
noremap! jj <ESC>

" autocmd BufRead,BufNewFile *.md set filetype=markdown  " md is markdown
" autocmd BufRead,BufNewFile *.md set spell
" autocmd VimResized * :wincmd =                         " automatically rebalance windows on vim resize

" Fix Cursor in TMUX
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Don't copy the contents of an overwritten selection.
" vnoremap p "_dP

" set nocursorline " don't highlight current line

" keyboard shortcuts

set hlsearch                     " highlight search
nmap <leader>hl :let @/ = ""<CR> " escape/unhighlight search

" Spell check prose only.
"
" This used to be a bare `set spell spelllang=en_us`, which flagged every
" identifier in every source file. It also made startup fragile: on a machine
" with no en.utf-8.spl installed, vim prompts to download the spell file over
" the network, which hangs or fails behind a restrictive proxy.
augroup SpellProse
  autocmd!
  autocmd FileType markdown,text,gitcommit setlocal spell spelllang=en_us
augroup END
" gui settings
" Force to use underline for spell check results
augroup SpellUnderline
  autocmd!
  autocmd ColorScheme *
    \ highlight SpellBad
    \   cterm=underline
    \   ctermfg=NONE
    \   ctermbg=NONE
    \   term=Reverse
    \   gui=Undercurl
    \   guisp=Red
  autocmd ColorScheme *
    \ highlight SpellCap
    \   cterm=underline
    \   ctermfg=NONE
    \   ctermbg=NONE
    \   term=Reverse
    \   gui=Undercurl
    \   guisp=Red
  autocmd ColorScheme *
    \ highlight SpellLocal
    \   cterm=underline
    \   ctermfg=NONE
    \   ctermbg=NONE
    \   term=Reverse
    \   gui=Undercurl
    \   guisp=Red
  autocmd ColorScheme *
    \ highlight SpellRare
    \   cterm=underline
    \   ctermfg=NONE
    \   ctermbg=NONE
    \   term=Reverse
    \   gui=Undercurl
    \   guisp=Red
  augroup END
colorscheme solarized

filetype plugin on

" 'longest' will change the 'completeopt' option so that Vim's popup menu
" doesn't select the first completion item, but rather just inserts the
" longest common text of all matches.
" 'menuone' changes the menu so it'll come up even if there's only one match.
set completeopt=longest,menuone
" Change the behavior of the <Enter> key when the popup menu is visible. In
" that case the Enter key will simply select the highlighted menu item, just
" as <C-Y> does.
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Make <C-N> work the way it normally does; however, when the menu appears,
" the <Down> key will be simulated. What this accomplishes is it keeps a menu
" item always highlighted. This way you can keep typing characters to narrow
" the matches, and the nearest match will be selected so that you can hit
" Enter at any time to insert it.
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <C-j> pumvisible() ? "\<lt>Down>" : '<C-j>'
inoremap <expr> <C-k> pumvisible() ? "\<lt>Up>" : '<C-k>'
" Note: Determine if this mapping is still needed.
" Simulates <C-X><C-O> to bring up the omni completion menu, then it simulates
" <C-N><C-P> to remove the longest common text, and finally it simulates
" <Down> again to keep a match highlighted.
inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

" Modular plugin & topic configurations (vimrc.d/*.vim & autoload/*.vim)
" -----------------------------------------------------------------------------------------------------------------------
let s:vimrc_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
if index(split(&runtimepath, ','), s:vimrc_dir) == -1
  execute 'set runtimepath^=' . fnameescape(s:vimrc_dir)
endif
for s:cfg in sort(glob(s:vimrc_dir . '/vimrc.d/*.vim', 0, 1))
  execute 'source' fnameescape(s:cfg)
endfor

" Modular variant overrides (managed by Makefile variants)
" -----------------------------------------------------------------------------------------------------------------------
if filereadable(expand('~/.vimrc.variant'))
  source ~/.vimrc.variant
endif

" Machine-local overrides (not tracked in this repo)
" -----------------------------------------------------------------------------------------------------------------------
"
" Anything specific to one machine or one employer goes in ~/.vimrc.local:
" linters and fixers for an internal toolchain, absolute paths, host-specific
" settings. Keeping it out of the tracked vimrc means this repo stays
" publishable, and it removes the reason to fork a per-employer branch and
" push it to a public remote.
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
