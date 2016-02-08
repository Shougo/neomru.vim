"=============================================================================
" FILE: neomru.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

if exists('g:loaded_neomru')
      \ || ($SUDO_USER != '' && $USER !=# $SUDO_USER
      \     && $HOME !=# expand('~'.$USER)
      \     && $HOME ==# expand('~'.$SUDO_USER))
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! NeoMRUReload call neomru#_reload()
command! NeoMRUSave call neomru#_save()

command! -nargs=? -complete=file NeoMRUImportFile
      \ call neomru#_import_file(<q-args>)
command! -nargs=? -complete=file NeoMRUImportDirectory
      \ call neomru#_import_directory(<q-args>)

augroup neomru
  autocmd!
  autocmd BufEnter,VimEnter,BufWinEnter,BufWritePost *
        \ call s:append(expand('<amatch>'))
  autocmd VimLeavePre *
        \ call neomru#_save({'event' : 'VimLeavePre'})
augroup END

let g:loaded_neomru = 1

function! s:append(path) abort "{{{
  if bufnr('%') != expand('<abuf>')
        \ || a:path == ''
    return
  endif

  call neomru#_append()
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" __END__
" vim: foldmethod=marker
