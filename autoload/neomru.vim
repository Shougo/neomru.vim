"=============================================================================
" FILE: neomru.vim
" AUTHOR:  Zhso Cai <caizhaoff@gmail.com>
"          Shougo Matsushita <Shougo.Matsu at gmail.com>
" Last Modified: 15 Feb 2014.
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

let s:save_cpo = &cpo
set cpo&vim

let s:is_windows = has('win16') || has('win32') || has('win64') || has('win95')

function! neomru#set_default(var, val, ...)  "{{{
  if !exists(a:var) || type({a:var}) != type(a:val)
    let alternate_var = get(a:000, 0, '')

    let {a:var} = exists(alternate_var) ?
          \ {alternate_var} : a:val
  endif
endfunction"}}}
function! s:substitute_path_separator(path) "{{{
  return s:is_windows ? substitute(a:path, '\\', '/', 'g') : a:path
endfunction"}}}

" Variables  "{{{
" The version of MRU file format.
let s:VERSION = '0.3.0'

call neomru#set_default(
      \ 'g:neomru#do_validate', 1,
      \ 'g:unite_source_mru_do_validate')
call neomru#set_default(
      \ 'g:neomru#update_interval', 600,
      \ 'g:unite_source_mru_update_interval')
call neomru#set_default(
      \ 'g:neomru#time_format', '',
      \ 'g:unite_source_file_mru_time_format')
call neomru#set_default(
      \ 'g:neomru#filename_format', '',
      \ 'g:unite_source_file_mru_filename_format')
call neomru#set_default(
      \ 'g:neomru#file_mru_path',
      \ s:substitute_path_separator(
      \  expand('~/.cache/neomru/file')),
      \ 'g:unite_source_file_mru_file',)
call neomru#set_default(
      \ 'g:neomru#file_mru_long_path',
      \ s:substitute_path_separator(
      \  expand('~/.cache/neomru/file_long')),
      \ 'g:unite_source_file_mru_long_file')
call neomru#set_default(
      \ 'g:neomru#file_mru_limit',
      \ 100, 'g:unite_source_file_mru_limit')
call neomru#set_default(
      \ 'g:neomru#file_mru_long_limit',
      \ 1000, 'g:unite_source_file_mru_long_limit')
call neomru#set_default(
      \ 'g:neomru#file_mru_ignore_pattern',
      \'\~$\|\.\%(o\|exe\|dll\|bak\|zwc\|pyc\|sw[po]\)$'
      \'\|\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)'
      \'\|^\%(\\\\\|/mnt/\|/media/\|/temp/\|/tmp/\|\%(/private\)\=/var/folders/\)'
      \'\|\%(^\%(fugitive\)://\)'
      \, 'g:unite_source_file_mru_ignore_pattern')

call neomru#set_default(
      \ 'g:neomru#directory_mru_path',
      \ s:substitute_path_separator(
      \  expand('~/.cache/neomru/directory')),
      \ 'g:unite_source_directory_mru_file')
call neomru#set_default(
      \ 'g:neomru#directory_mru_long_path',
      \ s:substitute_path_separator(
      \  expand('~/.cache/neomru/directory_long')),
      \ 'g:unite_source_directory_mru_long_file')
call neomru#set_default(
      \ 'g:neomru#directory_mru_limit',
      \ 100, 'g:unite_source_directory_mru_limit')
call neomru#set_default(
      \ 'g:neomru#directory_mru_long_limit',
      \ 1000, 'g:unite_source_directory_mru_long_limit')
call neomru#set_default(
      \ 'g:neomru#directory_mru_ignore_pattern',
      \'\%(^\|/\)\.\%(hg\|git\|bzr\|svn\)\%($\|/\)'
      \'\|^\%(\\\\\|/mnt/\|/media/\|/temp/\|/tmp/\|\%(/private\)\=/var/folders/\)',
      \ 'g:unite_source_directory_mru_ignore_pattern')
"}}}

" MRUs  "{{{
let s:MRUs = {}

" Template MRU:  "{{{2
"---------------------%>---------------------
" @candidates:
" ------------
" [full_path, ... ]
"
" @mtime
" ------
" the last modified time of the mru file.
" - set once when loading the short mru_file
" - update when #save()
"
" @is_loaded
" ----------
" 0: empty
" 1: short
" 2: long
" -------------------%<---------------------

let s:mru = {
      \ 'candidates'      : [],
      \ 'type'            : '',
      \ 'mtime'           : 0,
      \ 'update_interval' : g:neomru#update_interval,
      \ 'mru_file'        : {},
      \ 'limit'           : {},
      \ 'do_validate'     : g:neomru#do_validate,
      \ 'is_loaded'       : 0,
      \ 'version'         : s:VERSION,
      \ }

function! s:mru.is_a(type) "{{{
  return self.type == a:type
endfunction "}}}
function! s:mru.save(...)
    throw 'unite(mru) umimplemented method: save()!'
endfunction
function! s:mru.load()
    throw 'unite(mru) umimplemented method: load()!'
endfunction
function! s:mru.validate()
    throw 'unite(mru) umimplemented method: validate()!'
endfunction

function! s:mru.gather_candidates(args, context) "{{{
  if empty(self.candidates)
    call self.load()
  endif

  let self.candidates = unite#sources#mru#variables#get_mrus(self.type)
        \ + self.candidates
  call unite#sources#mru#variables#clear(self.type)

  if a:context.is_redraw && g:neomru#do_validate
    call filter(self.candidates,
          \ ((self.type == 'file') ?
          \ "v:val !~ '^\\a\\w\\+:'
          \       && filereadable(v:val)" :
          \ "isdirectory(v:val)"))
  endif

  if get(a:args, 0, '') =~# '\%(long\|all\|\*\|_\)'
      \ || a:context.is_redraw
    call self.load()
    let candidates = self.candidates
  else
    let candidates = self.candidates[: self.limit.short]
  endif

  return map(copy(candidates), "{
        \ 'word' : v:val,
        \ 'action__path' : v:val,
        \}")
endfunction"}}}
function! s:mru.delete(candidates) "{{{
  for candidate in a:candidates
    call filter(self.candidates,
          \ 'v:val !=# candidate.action__path')
  endfor

  call self.save()
endfunction"}}}
function! s:mru.has_external_update() "{{{
  return self.mtime < getftime(self.mru_file.short)
      \ || self.mtime < getftime(self.mru_file.long)
endfunction"}}}

function! s:mru.save(...) "{{{
  let opts = {}
  if a:0 >= 1 && type(a:1) == type({})
    call extend(opts, a:1)
  endif

  if empty(unite#sources#mru#variables#get_mrus(self.type))
    " nothing to save, mru is not loaded
    return
  endif

  let self.candidates = []

  " should load all candidates
  call self.load(1) " load short candidates
  call self.load(1) " load long candidates

  let self.candidates = unite#sources#mru#variables#get_mrus(self.type)
        \ + self.candidates
  call unite#sources#mru#variables#clear(self.type)

  if self.has_external_update() && filereadable(self.mru_file.short)
    " only need to get the short list which contains the latest MRUs
    let [ver; items] = readfile(self.mru_file.short)
    if self.version_check(ver)
      call extend(self.candidates, items)
    endif
  endif

  let self.candidates = s:uniq(self.candidates)

  if get(opts, 'event') ==# 'VimLeavePre'
    call self.validate()
  endif

  call s:writefile(self.mru_file.short,
        \ [self.version] +
        \ self.candidates[: self.limit.short - 1])

  if len(self.candidates) > self.limit.short
    call s:writefile(self.mru_file.long,
          \ [self.version] +
          \ self.candidates[self.limit.short : self.limit.long - 1])
    let self.mtime = getftime(self.mru_file.long)
  else
    let self.mtime = getftime(self.mru_file.short)
  endif
endfunction"}}}

function! s:mru.load(...)  "{{{
  let is_force = get(a:000, 0, 0)

  " everything is loaded, done!
  if !is_force && self.is_loaded >= 2
    return
  endif

  " Load Order:
  " 1. (load)  short mru list
  " 2. (merge) long list on_redraw
  let mru_file = empty(self.candidates) ?
        \ self.mru_file.short : self.mru_file.long

  if !filereadable(mru_file)
    return
  endif

  let file = readfile(mru_file)
  if empty(file)
    return
  endif

  let [ver; items] = file
  if !self.version_check(ver)
    return
  endif

  " Assume properly saved and sorted. unique sort is not necessary here
  call extend(self.candidates, items)

  let self.candidates = s:uniq(self.candidates)

  if mru_file == self.mru_file.short
    let self.mtime = getftime(mru_file)
    let self.is_loaded = 1
  elseif mru_file == self.mru_file.long
    let self.is_loaded = 2
  endif
endfunction"}}}
function! s:mru.version_check(ver)  "{{{
  if str2float(a:ver) < self.version
    call unite#util#print_error(
          \ 'Sorry, the version of MRU file is old.')
    return 0
  else
    return 1
  endif
endfunction"}}}

"}}}

" File MRU:   "{{{2
"
let s:file_mru = extend(deepcopy(s:mru), {
      \ 'type'          : 'file',
      \ 'mru_file'      : {
      \   'short' : g:neomru#file_mru_path,
      \   'long'  : g:neomru#file_mru_long_path,
      \  },
      \ 'limit'         : {
      \   'short' : g:neomru#file_mru_limit,
      \   'long'  : g:neomru#file_mru_long_limit,
      \  },
      \ }
      \)
function! s:file_mru.validate()  "{{{
  if self.do_validate
    call filter(self.candidates, 'getftype(v:val) ==# "file"')
  endif
endfunction"}}}

" Directory MRU:   "{{{2
let s:directory_mru = extend(deepcopy(s:mru), {
      \ 'type'          : 'directory',
      \ 'mru_file'      : {
      \   'short' : g:neomru#directory_mru_path,
      \   'long'  : g:neomru#directory_mru_long_path,
      \  },
      \ 'limit'         : {
      \   'short' : g:neomru#directory_mru_limit,
      \   'long'  : g:neomru#directory_mru_long_limit,
      \  },
      \ }
      \)

function! s:directory_mru.validate()  "{{{
  if self.do_validate
    call filter(self.candidates, 'getftype(v:val) ==# "dir"')
  endif
endfunction"}}}
"}}}

" Public Interface:   "{{{2

let s:MRUs.file = s:file_mru
let s:MRUs.directory = s:directory_mru
function! neomru#init()  "{{{
endfunction"}}}
function! neomru#_get_mrus()  "{{{
  return s:MRUs
endfunction"}}}
function! neomru#_save(...) "{{{
  let opts = {}
  if a:0 >= 1 && type(a:1) == type({})
    call extend(opts, a:1)
  endif

  for m in values(s:MRUs)
    call m.save(opts)
  endfor
endfunction"}}}
"}}}
"}}}

" Misc "{{{
function! s:writefile(path, list) "{{{
  if !isdirectory(fnamemodify(a:path, ':p:h'))
    call mkdir(fnamemodify(a:path, ':p:h'), 'p')
  endif

  call writefile(a:list, a:path)
endfunction"}}}
function! s:uniq(list, ...) "{{{
  return s:uniq_by(a:list, 'v:val')
endfunction"}}}
function! s:uniq_by(list, f) "{{{
  let list = map(copy(a:list), printf('[v:val, %s]', a:f))
  let i = 0
  let seen = {}
  while i < len(list)
    let key = string(list[i][1])
    if has_key(seen, key)
      call remove(list, i)
    else
      let seen[key] = 1
      let i += 1
    endif
  endwhile
  return map(list, 'v:val[0]')
endfunction"}}}
"}}}
"
let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
