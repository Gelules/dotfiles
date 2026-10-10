""""""""""""""""""""""""""""""""""""""""""""""""""
" Description:
"   This is the .vimrc file
"
" Maintainer:
"   Jules Aubert
"
" Acknowledgements:
"   Several elements of this .vimrc come from Chewie's config
"   You can find it here: https://github.com/Chewie/dotfiles/
"
""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" General parameters
""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO: At some point I'll need to switch over to the native Vim 8.0 package
" feature. Either via manual git subtree management, or maybe through minpac?
"
" Install vim-plug if we don't already have it, then the missing plugins
" (fresh machine). Snippets from the vim-plug README and wiki.
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
" Offline first start: no plug.vim, so skip the plugins instead of erroring
if filereadable(expand('~/.vim/autoload/plug.vim'))
    augroup plug_install_missing
        autocmd!
        autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif
    augroup END

    call plug#begin('~/.vim/plugged')

    " Bag of mappings
    Plug 'tpope/vim-surround'
    Plug 'romainl/vim-qf'

    " Navigation

    " Theming
    Plug 'nanotech/jellybeans.vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'luochen1990/rainbow'

    " Tag management
    Plug 'preservim/tagbar'

    " 'IDE' features
    Plug 'tpope/vim-fugitive'
    Plug 'yegappan/lsp'

    call plug#end()
endif

" Enable filetype detection for plugins and indentation options
filetype plugin indent on

" Reload a file when it is changed from the outside
set autoread

" Write the file when we leave the buffer
set autowrite

" Disable backups, we have source control for that
set nobackup

" Force encoding to utf-8, for systems where this is not the default (windows
" comes to mind)
set encoding=utf-8

" Disable swapfiles too
set noswapfile

" Hide buffers instead of closing them
set hidden

" Set the time (in milliseconds) spent idle until various actions occur
" In this configuration, it is particularly useful for the tagbar plugin
set updatetime=500

" Don't wait a full second after <Esc> for a terminal key code (defaults.vim
" sets this, but it is not loaded when a ~/.vimrc exists)
set ttimeout ttimeoutlen=50

""""""""""""""""""""""""""""""""""""""""""""""""""
" User interface
""""""""""""""""""""""""""""""""""""""""""""""""""

" Make backspace behave as expected
set backspace=eol,indent,start

" Set the minimal amount of lignes under and above the cursor
" Useful for keeping context when moving with j/k
set scrolloff=5

" Show current mode
set showmode

" Show command being executed
set showcmd

" Show line number
set number

" Always show status line
set laststatus=2

" Enhance command line completion
set wildmenu

" Set completion behavior, see :help wildmode for details
set wildmode=longest:full,list:full

" Disable bell completely
set visualbell
set t_vb=

" Color the column after textwidth, usually the 80th
set colorcolumn=+1

" Display whitespace characters
set list
set listchars=tab:>─,eol:¬,trail:\ ,nbsp:¤

set fillchars=vert:│

" Enables syntax highlighting
syntax on

" Enable Doxygen highlighting
let g:load_doxygen_syntax=1

" Allow mouse use in vim
set mouse=a

" Briefly show matching braces, parens, etc
set showmatch

" Enable line wrapping
set wrap

" Wrap on column 80
set textwidth=80

" Disable preview window on completion
set completeopt=longest,menuone

" Highlight current line
set cursorline

""""""""""""""""""""""""""""""""""""""""""""""""""
" Search options
""""""""""""""""""""""""""""""""""""""""""""""""""

" Ignore case on search
set ignorecase

" Ignore case unless there is an uppercase letter in the pattern
set smartcase

" Move cursor to the matched string
set incsearch

" Don't highlight matched strings
set nohlsearch

""""""""""""""""""""""""""""""""""""""""""""""""""
" Indentation options
""""""""""""""""""""""""""""""""""""""""""""""""""

" The length of a tab
" This is for documentation purposes only,
" do not change the default value of 8, ever.
set tabstop=8

" The number of spaces inserted/removed when using < or >
set shiftwidth=4

" The number of spaces inserted when you press tab.
" -1 means the same value as shiftwidth
set softtabstop=-1

" Insert spaces instead of tabs
set expandtab

" When tabbing manually, use shiftwidth instead of tabstop and softtabstop
set smarttab

" Set basic indenting (i.e. copy the indentation of the previous line)
" When filetype detection didn't find a fancy indentation scheme
set autoindent

" This one is complicated. See :help cinoptions-values for details
set cinoptions=(0,u0,U0,t0,g0,N-s

""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""

" Set "," as map leader
let mapleader = ","

" Launch fugitive's status window
nnoremap <leader>gs :Git<CR>

" Toggle paste mode
noremap <leader>pp :setlocal paste!<cr>

" Move between rows in wrapped lines (Normal and Visual only: dj, yk, >j stay linewise)
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

" Yank from cursor to end of line, to be consistent with C and D
nnoremap Y y$

" Write as root, when you forgot to sudoedit
cnoreabbrev w!! w !sudo tee % >/dev/null

" map ; to :
noremap ; :

" Open the quickfix window if there are errors, or close it if there are no
" errors left
noremap <leader>cw :botright :cw<cr>

" Add the termdebug built-in package
packadd! termdebug

" Run make silently, then skip the 'Press ENTER to continue'
noremap <leader>m :silent! :make! \| :redraw!<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""
" Persistence options
""""""""""""""""""""""""""""""""""""""""""""""""""

" Set location of the viminfo file
set viminfo='20,\"50,<100,n~/.vimtmp/viminfo

" See :h last-position-jump
augroup last_position_jump
    autocmd!
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

" Persistent undo
set undofile
set undodir=~/.vimtmp/undo
call mkdir(expand('~/.vimtmp/undo'), 'p', 0o700)
" Not for temporary files: sudoedit copies of /etc files land in /var/tmp
augroup no_undo_tmp
    autocmd!
    autocmd BufWritePre /tmp/*,/var/tmp/*,/dev/shm/* setlocal noundofile
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugin mappings and options
""""""""""""""""""""""""""""""""""""""""""""""""""

" Use a slightly darker background color to differentiate with the status line
let g:jellybeans_background_color_256='NONE'

" Feel free to switch to another colorscheme
silent! colorscheme jellybeans   " silent!: not installed yet on a fresh machine

" Rainbow parentheses
let g:rainbow_active = 1

" vim-qf: wrap-around quickfix and location-list navigation
nmap [q <Plug>(qf_qf_previous)
nmap ]q <Plug>(qf_qf_next)
nmap [l <Plug>(qf_loc_previous)
nmap ]l <Plug>(qf_loc_next)

" LSP (yegappan/lsp): clangd comes with the clang package, rust-analyzer with
" `rustup component add rust-analyzer` (rustup's proxy always exists, so ask rustup
" for the real binary). Servers that are not installed are skipped.
let lspServers = filter([
    \ #{name: 'clangd', filetype: ['c', 'cpp'], path: exepath('clangd'), args: ['--background-index']},
    \ #{name: 'rust-analyzer', filetype: ['rust'], args: [], syncInit: v:true,
    \   path: executable('rustup') ? trim(system('rustup which rust-analyzer 2>/dev/null')) : exepath('rust-analyzer')},
    \ ], '!empty(v:val.path)')
augroup lsp_setup
    autocmd!
    autocmd User LspSetup call LspAddServer(lspServers)
    autocmd User LspAttached nnoremap <buffer> gd <Cmd>LspGotoDefinition<CR>
    autocmd User LspAttached nnoremap <buffer> K <Cmd>LspHover<CR>
augroup END
