"=============================================================================
" FILE: autoload/unite/sources/historia.vim
" AUTHOR: haya14busa
" Last Change: 21-07-2014.
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
scriptencoding utf-8
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

call unite#util#set_default('g:unite_source_historia_command_file',
\   unite#get_data_directory() . '/historia_command')

let s:historia_file_mtime = 0

function! unite#sources#historia#define() "{{{
    return s:source
endfunction "}}}

let s:source = {
      \ 'name' : 'historia/command',
      \ 'description' : 'extended candidates from command history',
      \ 'default_kind' : 'word',
      \}

function! s:source.gather_candidates(args, context) "{{{
    call unite#sources#historia#_append()
    return map(copy(s:load()), "{
    \     'word' : v:val
    \   , 'abbr' : ':' . v:val
    \   , 'kind' : 'command'
    \   , 'action__command' : v:val
    \   , 'action__histadd': 1
    \   }")
endfunction "}}}

function! unite#sources#historia#_append() "{{{
    let new_hist = filter(map(reverse(range(1, histnr(':')))
    \                        , 'histget(":", v:val)')
    \                    , 'v:val !=# ""')
    call s:save(unite#util#uniq(new_hist + s:load()))
endfunction "}}}

function! s:save(histories) "{{{
    if g:unite_source_historia_command_file == '' || unite#util#is_sudo()
        return
    endif

    let s:historia = a:histories
    call writefile([string(a:histories)], g:unite_source_historia_command_file)
    let s:historia_file_mtime = getftime(g:unite_source_historia_command_file)
endfunction "}}}

function! s:load()  "{{{
    if s:historia_file_mtime == getftime(g:unite_source_historia_command_file)
    \ && exists('s:historia')
        return s:historia
    endif

    if !filereadable(g:unite_source_historia_command_file)
        return []
    endif

    let file = readfile(g:unite_source_historia_command_file)
    if empty(file)
        return []
    endif

    try
        sandbox let s:historia = eval(file[0])
    catch
        let s:historia = []
    endtry

    let s:historia_file_mtime = getftime(g:unite_source_historia_command_file)

    return s:historia
endfunction "}}}

let s:source_command_new = {
\   "name" : "command/new",
\}

function! s:source_command_new.change_candidates(args, context)
    let word = a:context.input
    if word == ""
        let word = "[new command]"
    endif
    return [{
\       "word" : word,
\       "kind" : "command",
\       "action__command" : word,
\   }]
endfunction

call unite#define_source(s:source_command_new)

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
unlet s:save_cpo
" }}}
" __END__  {{{
" vim: expandtab softtabstop=4 shiftwidth=4
" vim: foldmethod=marker
" }}}
