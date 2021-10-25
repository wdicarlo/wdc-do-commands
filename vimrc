" Vim with all enhancements
" When started as "evim", evim.vim will already have done these settings, bail
" out.
"if v:progname =~? "evim"
"  finish
"endif

" Get the defaults that most users want.
source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 120 characters.
  autocmd FileType text setlocal textwidth=120
augroup END

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

set cmdheight=2 " to avoid to hit Enter at each message
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'vimwiki/vimwiki'
Plug 'itchyny/calendar.vim'
Plug 'mechatroner/rainbow_csv'
Plug 'godlygeek/tabular' 
Plug 'hashivim/vim-terraform' 
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive' 
Plug 'junegunn/gv.vim'
Plug 'kamykn/spelunker.vim' " spelling check
Plug 'tpope/vim-obsession'
Plug 'vimoutliner/vimoutliner'
Plug 'wdicarlo/vim-notebook'
Plug 'vim-voom/VOoM'
Plug 'will133/vim-dirdiff'
Plug 'skywind3000/asyncrun.vim'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

colorscheme desert

let g:vimwiki_list = [{'path': '~/projects', 'auto_toc': 1, 'nested_syntaxes': {'python': 'python', 'go': 'go', 'bash': 'bash'}},
			\{'path': '~/wiki/', 'path_html': '~/public_html/'}]
let g:vimwiki_auto_chdir = 1
let g:vimwiki_folding = 'expr'
let g:vimwiki_auto_header = 1
let g:vimwiki_toc_header = 'table_of_contents'
set nofoldenable
autocmd FileType vimwiki nnoremap <buffer> <Leader>wT :VimwikiTOC<CR>
:nmap <Leader><Leader>vw :VimwikiIndex<CR>

" Window size appearance
augroup guiappearance
  au!
  set guifont=Consolas:h12
  :map <F7> :set guifont=Consolas:h12<CR>
  :map <S-F7> :set guifont=Consolas:h10<CR>
  :map <C-F7> :set guifont=Consolas:h14<CR>
  :map <F9> :set lines+=5<CR>
  :map <S-F9> :set lines-=5<CR>
  :map <C-F9> :set lines=60<CR>
  :map <M-F9> :set lines=30<CR>
  :map <F8> :set columns+=10<CR>
  :map <S-F8> :set columns-=10<CR>
  :map <C-F8> :set columns=175<CR>
  :map <M-F8> :set columns=80<CR>
  :map <F10> :set columns=175<CR>:set lines=60<cr>
augroup END

set tabstop=2 shiftwidth=2 expandtab
set nowrap
let g:calendar_week_number = 1
let g:calendar_view = "year"
:nmap <Leader>wC :Calendar -position=below -height=12<CR>
:nmap <Leader>wS :!"C:\Program Files\Git\git-bash.exe"<CR>
:nmap <Leader>wB :term "C:\Program Files\Git\bin\bash.exe"<CR>


augroup vimwiki_tab
    autocmd!
    autocmd FileType vimwiki nnoremap <buffer> <tab> >>
    autocmd FileType vimwiki nnoremap <buffer> <s-tab> <<
    autocmd FileType vimwiki vnoremap <buffer> <tab> >>
    autocmd FileType vimwiki vnoremap <buffer> <s-tab> <<

    autocmd FileType vimwiki imap <buffer> <tab> <c-t>
    autocmd FileType vimwiki imap <buffer> <s-tab> <c-d>

    autocmd FileType vimwiki inoremap <buffer> <c-tab> <tab>
augroup END

set backupdir=/media/shared/vim/backups//,/tmp//
set directory=/media/shared/vim/backups//,/tmp//
set undodir=/media/shared/vim/backups//,/tmp//


let g:terraform_align=1
let g:terraform_fold_sections=1


:hi CursorLine   cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
:hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white guibg=darkred guifg=white
:nnoremap <Leader><leader>c :set cursorline! cursorcolumn!<CR>

set hidden
 
 
" vim-obsession {
" enable/disable vim-obsession integration
let g:airline#extensions#obsession#enabled = 1

" set marked window indicator string
let g:airline#extensions#obsession#indicator_text = '$'
" }

" clipboard {
    function! Getclip()
      let reg_save = @@
      let @@ = system('getclip')
      setlocal paste
      exe 'normal p'
      setlocal nopaste
      let @@ = reg_save
    endfunction


    function! Putclip(type, ...) range
      let sel_save = &selection
      let &selection = "inclusive"
      let reg_save = @@
      if a:type == 'n'
        silent exe a:firstline . "," . a:lastline . "y"
      elseif a:type == 'c'
        silent exe a:1 . "," . a:2 . "y"
      else
        silent exe "normal! `<" . a:type . "`>y"
      endif
      call system('putclip', @@)
      let &selection = sel_save
      let @@ = reg_save
    endfunction

    function! CutClip(type, ...) range
      let sel_save = &selection
      let &selection = "inclusive"
      let reg_save = @@

      if a:type == 'n'
        silent exe a:firstline . "," . a:lastline . "d"
      elseif a:type == 'c'
        silent exe a:1 . "," . a:2 . "d"
      else
        silent exe "normal! `<" . a:type . "`>d"
      endif
      call system('putclip', @@)

      let &selection = sel_save
      let @@ = reg_save
    endfunction

    vnoremap <silent> <leader>y :call Putclip(visualmode(), 1)<CR>
    nnoremap <silent> <leader>y :call Putclip('n', 1)<CR>
    nnoremap <silent> <leader>p :call Getclip()<CR>
    " Cut via \x in normal or visual mode.
    vnoremap <silent> <leader>x :call CutClip(visualmode(), 1)<CR>
    nnoremap <silent> <leader>x :call CutClip('n', 1)<CR>
" }

" highlithing {
    function! AddTextToHL (text,reset) 
      if a:reset == 1
        let @/=""
      endif

      if @/ != ""
        :let @/ = @/."\\|".a:text
      else
        :let @/ = a:text
      endif
    endfunction
    nmap + :call AddTextToHL ( expand("<cword>"), 0 )<cr>
    vmap + :call AddTextToHL ( GetVisual(), 0 )<cr>

    function! RemoveTextFromHL (text)
      let @/ = substitute( @/, a:text."\\\\|", "", "" )
      let @/ = substitute( @/, "\\\\|".a:text, "", "" )
      let @/ = substitute( @/, a:text, "", "" )
    endfunction
    nmap - :call RemoveTextFromHL ( expand("<cword>") )<CR>
    vmap - :call RemoveTextFromHL ( GetVisual() )<CR>

    nmap _ :let @/=""<CR>
" }
" key mapping {
    " Making it so ; works like : for commands. Saves typing and eliminates :W style typos due to lazy holding shift.
    "nnoremap ; :

    " Go backward/forward
    nmap <a-left> :normal! <c-o><cr>
    nmap <a-right> :normal! <c-i><cr>

    " Easier moving in tabs and windows
    map <C-J> <C-W>j<C-W>_
    map <C-K> <C-W>k<C-W>_
    map <C-L> <C-W>l<C-W>_
    map <C-H> <C-W>h<C-W>_

    "nmap <C-t><right> :tabnext<CR>
    "nmap <C-t><left> :tabprev<CR>
    nnoremap <C-k>   :tabnext<CR>
    nnoremap <C-j>   :tabprevious<CR>
    inoremap <C-k>   <Esc>:tabnext<CR>    
    inoremap <C-j> <Esc>:tabprevious<CR>
    nmap <C-t>n :tabnew<CR>
    nmap <c-t>q :windo exec "bd"<cr>
    nmap <c-t>qq :windo exec "bd!"<cr>

    " The following maps help with window resizing...
    nmap <C-up> <C-w>+
    nmap <C-down> <C-w>-
    nmap <C-left> <C-w><
    nmap <C-right> <C-w>>

    " scroll without moving the cursor
    nmap <s-j> <c-e>j
    nmap <s-k> <c-y>k

    " Stupid shift key fixes
    "map W w
    cmap WQ wq
    cmap wQ wq
    cmap WQ wq
    cmap Wq wq
    cmap Wqa wqa
    cmap Qa qa
    cmap qA qa
    cmap QA qa
    "cmap Q q
    cmap Tabe tabe

    """ Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>
" }

" line mapping {
    nmap <leader>lj :join<CR>
" }

" dirdiff {
let g:DirDiffExcludes=".git"
" }

" gv {
" Commands
"  :GV to open commit browser
"      You can pass git log options to the command, e.g. :GV -S foobar -- plugins.
"  :GV! will only list commits that affected the current file
"  :GV? fills the location list with the revisions of the current file
"  :GV or :GV? can be used in visual mode to track the changes in the selected lines.
" Mappings
"  o or <cr> on a commit to display the content of it
"  o or <cr> on commits to display the diff in the range
"  O opens a new tab instead
"  gb for :GBrowse
"  ]] and [[ to move between commits
"  . to start command-line with :Git [CURSOR] SHA à la fugitive
"  q or gq to close
" }
" savever {
set patchmode=.sav
let savevers_types = "*.txt,*.vim,*.otl,*.nb,*.md,*.wiki,.vimrc"
let savevers_max   = 10
let savevers_dirs = &backupdir
" }

" asyncrun {
"set g:asyncrun_open=5
" }

" vim-git-backup {
"let g:custom_backup_dir = "/media/shared/vim/backups/"
"let g:custom_backup_dir = "~/backups/vim"
" }

" vim-custom-git-custom {
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Vim Git Backup
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup custom_backup
  autocmd!
  autocmd BufWritePost * call GBackupCurrentFile()
augroup end
 
command! -nargs=0 GBackupCurrentFile :call GBackupCurrentFile()
command! -nargs=0 GBackupHistory :call GBackupHistory()

" backup dir
let s:custom_backup_dir='/media/shared/vim/backups/vim_git_backup.git'


function! GBackupCurrentFile()
  if !isdirectory(expand(s:custom_backup_dir))
    " init git repository
    let cmd = 'mkdir -p ' . s:custom_backup_dir . ';'
    let cmd .= 'cd ' . s:custom_backup_dir . ';'
    let cmd .= 'git init;'
    let cmd .= 'git config user.name "Walter Di Carlo";'
    let cmd .= 'git config user.email "walter@di-carlo.it";'
    call system(cmd)
  endif
  let file = expand('%:p')
  if file =~ fnamemodify(s:custom_backup_dir, ':t') | return | endif
  let projects_dir = fnamemodify('~/projects', ':p')
  if stridx(file,projects_dir) == -1 | echohl WarningMsg | echo "Skipping backup of: ".file | echohl None | return | endif " skip backup of files not under projects folder
  echomsg "Backup of: ".file
  let file_dir = s:custom_backup_dir . expand('%:p:h')
  let backup_file = s:custom_backup_dir . file
  let cmd = ''
  if !isdirectory(expand(file_dir))
    let cmd .= 'mkdir -p ' . file_dir . ';'
  endif
  let curdate = strftime('%Y%m%d-%H:%M')
  let cmd .= 'cp ' . file . ' ' . backup_file . ';'
  let cmd .= 'cd ' . s:custom_backup_dir . ';'
  let cmd .= 'git add ' . backup_file . ';'
  let cmd .= 'git commit -m "'.curdate.';'.file.'";'

  call job_start(['sh', '-c', cmd])
endfunction

function! GBackupHistory()
    let backup_dir = expand(g:custom_backup_dir . expand('%:p:h'))
    let cmd = "cd " . backup_dir
    let cmd .= "; git log -p --since='1 month' " . expand('%:t')

    silent! exe "noautocmd botright pedit vim_git_backup"

    noautocmd wincmd P
    set buftype=nofile
    exe "noautocmd r! ".cmd
    exe "normal! gg"
    noautocmd wincmd p
endfunction
" }

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

