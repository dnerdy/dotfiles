set nocompatible              " be iMproved, required
filetype off                  " required

call plug#begin('~/.vim/plugged')

Plug 'gmarik/Vundle.vim'

Plug 'scrooloose/nerdtree'
Plug 'ervandew/supertab'
Plug 'kien/ctrlp.vim'

Plug 'tpope/vim-fugitive'
Plug 'Rykka/riv.vim'
Plug 'Rykka/InstantRst'

" syntax plugins
Plug 'jnwhiteh/vim-golang'
Plug 'digitaltoad/vim-jade'
Plug 'groenewege/vim-less'
Plug 'evanmiller/nginx-vim-syntax'
Plug 'kchmck/vim-coffee-script'
Plug 'chase/vim-ansible-yaml'
Plug 'cakebaker/scss-syntax.vim'

Plug 'dnerdy/vim-dnerdy'

call plug#end()

filetype plugin indent on    " required

let mapleader = ","
if has('gui_macvim') || has('gui_vimr')
    colorscheme blackboard
endif
set invlist
set number
filetype plugin indent on
set wildmode=longest,list,full
set visualbell

" Tabs!

set tabstop=4
set softtabstop=4
set shiftwidth=4
" set textwidth=100
set smarttab
set expandtab

"!!! Based on http://superuser.com/questions/608292/select-vimenter-autocmds-to-run-based-on-args
if argc() == 1 && isdirectory(argv(0))
    bd
    autocmd VimEnter * exec "cd" argv(0)
endif

map <D-p> :CtrlP<CR>
map <D-t> :CtrlP<CR>

" vim-multiple-cursors
" let g:multi_cursor_exit_from_visual_mode = 0
let g:multi_cursor_exit_from_insert_mode = 0

" Nifty shortcuts

nmap t :CommandT<CR>
command! C cd %:p:h

" .vimrc management

" au! BufWritePost .vimrc source %
" command! V :e $MYVIMRC

" For git integration

set autoread
set statusline=%m\ %F%=%{fugitive#statusline()}\ %c\ 

" Restore cursor postion

set viminfo='10,\"100,:20,%,n~/.viminfo

function! ResCur()
  if line("'\"") <= line("$")
    normal! g`"
    return 1
  endif
endfunction

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

" Commenting

vmap <D-/> \c<Space>

" Python debugging

nnoremap <c-i> Oimport pdb; pdb.set_trace()<Esc>
nnoremap <c-t> :execute ":!project-test" expand('%:p')  line('.')<cr>

function! ChangeTabStop(from, to)
    let &ts = a:from
    let &sts = a:from
    set noet
    retab!
    let &ts = a:to
    let &sts = a:to
    set et
    retab!
endfunction

command! -nargs=+ Cts call ChangeTabStop(<f-args>)

set wildignore+=*.pyc

" MiniBufExpl Colors
hi MBENormal               guifg=#808080 guibg=fg
hi MBEChanged              guifg=#CD5907 guibg=fg
hi MBEVisibleNormal        guifg=#5DC2D6 guibg=fg
hi MBEVisibleChanged       guifg=#F1266F guibg=fg
hi MBEVisibleActiveNormal  guifg=#A6DB29 guibg=fg
hi MBEVisibleActiveChanged guifg=#F1266F guibg=fg

" Ctrl-P

function! DnerdyCtrlPMatch(args)
" See: https://github.com/kien/ctrlp.vim/blob/master/doc/ctrlp.txt

python << endpython

import os
import vim

args = vim.eval('a:args')
terms = args['str'].split()

results = []

def find(item, term):
    index = item.find(term)

    if index < 0:
        return index
    if index == 0:
        return 2
    if item[index-1] == '/':
        return 2

    return 1

if len(terms):
    for item in args['items']:
        if args['ispath'] and item == args['crfile']:
            continue

        matches = True
        score = 0
        for term in terms:
            term_score = find(item, term)
            if term_score < 0:
                matches = False
                break
            score += term_score
            if term in os.path.basename(item):
                score += 1
        if matches:
            results.append((score, -len(item), item))

    results.sort(reverse=True)
    results = [x[-1] for x in results]
else:
    results = [item for item in args['items'] if item != args['crfile']]

vim.command('return ' + str(results[:int(args['limit'])]))

endpython

endfunction

let g:ctrlp_match_func = { 'match': 'DnerdyCtrlPMatch', 'arg_type': 'dict' }
let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': [],
  \ 'AcceptSelection("t")': ['<cr>', '<c-m>'],
  \ }

"""""" RST

augroup filetypedetect_rst
    au!
    " Headings
    au FileType rst nnoremap <leader>h1 ^yypv$r=o<cr><esc>
    au FileType rst inoremap <leader>h1 <esc>^yypv$r=o<cr>

    au FileType rst nnoremap <leader>h2 ^yypv$r-o<cr><cr><cr><cr><cr><cr><esc>kkkk
    au FileType rst inoremap <leader>h2 <esc>^yypv$r-o<cr><cr><cr><cr><cr><cr><esc>kkkki

    au FileType rst nnoremap <leader>h3 ^yypv$r+o<cr><cr><cr><cr><cr><cr><esc>kkkk
    au FileType rst inoremap <leader>h3 <esc>^yypv$r+o<cr><cr><cr><cr><cr><cr><esc>kkkki

    au FileType rst nnoremap <leader>h4 ^yypv$r~o<cr><cr><cr><cr><cr><cr><esc>kkkk
    au FileType rst inoremap <leader>h4 <esc>^yypv$r~o<cr><cr><cr><cr><cr><cr><esc>kkkki

    au FileType rst nnoremap <leader>h5 ^yypv$r*o<cr><cr><cr><cr><cr><cr><esc>kkkk
    au FileType rst inoremap <leader>h5 <esc>^yypv$r*o<cr><cr><cr><cr><cr><cr><esc>kkkki
    """Make Link (ml)
    " Highlight a word or phrase and it creates a link and opens a split so
    " you can edit the url separately. Once you are done editing the link,
    " simply close that split.
    au FileType rst vnoremap <leader>ml yi`<esc>gvvlli`_<esc>:vsplit<cr><C-W>l:$<cr>o<cr>.. _<esc>pA: http://TODO<esc>vb
    """Make footnote (ml)
    au FileType rst iabbrev mfn [#]_<esc>:vsplit<cr><C-W>l:$<cr>o<cr>.. [#] TODO
    au FileType rst set spell
    "Create image
    au FileType rst iabbrev iii .. image:: TODO.png<cr>    :scale: 100<cr>:align: center<cr><esc>kkkeel
    "Create figure
    "au FileType rst iabbrev iif .. figure:: TODO.png<cr>    :scale: 100<cr>:align: center<cr>:alt: TODO<cr><cr><cr>Some brief description<esc>kkkeel

    "Create note
    au FileType rst iabbrev nnn .. note:: 
    "Start or end bold text inline
    au FileType rst inoremap <leader>bb **
    "Start or end italicized text inline
    au FileType rst inoremap <leader>ii *
    "Start or end preformatted text inline
    au FileType rst inoremap <leader>pf ``

    " Fold settings
    "au FileType rst set foldmethod=marker
    
    " Admonitions
    au FileType rst iabbrev adw .. warning::
    au FileType rst iabbrev adn .. note::
augroup END

"""""" END RST

if has("gui_macvim")
    autocmd VimEnter * NERDTree
    autocmd VimEnter * wincmd w
endif
