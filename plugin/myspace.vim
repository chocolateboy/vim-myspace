" XXX probably doesn't work with folds
" TODO investigate removing the search pattern from history as per this SO answer:
" see: http://stackoverflow.com/a/23650554
" TODO add tests

if exists('g:myspace_loaded')
    finish
end

let g:myspace_loaded = v:true

if !exists('g:myspace_filetype')
    let g:myspace_filetype = {}
endif

if !exists('g:myspace_disable')
    let g:myspace_disable = v:false
endif

" return true if this plugin is disabled in the current buffer
" or globally; otherwise, return false
function s:IsDisabled()
    return exists('b:myspace_disable') ? b:myspace_disable : g:myspace_disable
endfunction

" expand or shrink the supplied space-prefix, mapping multiples of `from` spaces
" to the corresponding number of `to` spaces
function s:Replace(match, from, to)
    let quotient = strlen(a:match) / a:from
    let remainder = strlen(a:match) % a:from
    return repeat(' ', a:to * quotient + remainder)
endfunction

" signature: filetype: string → [match: boolean, from: integer, to: integer]
"
" given a filetype, return a [match, from, to] triple. if no mapping is
" registered for the filetype, `match` is false. otherwise, it's true
" and `from` and `to` are set to their configured values.
function s:Lookup(lang)
    let specs = exists('b:myspace_filetype') ? b:myspace_filetype : g:myspace_filetype

    for key in keys(specs)
        let langs = split(key, '|')

        if index(langs, a:lang) >= 0
            let spec = specs[key]

            if type(spec) == v:t_list && len(spec) == 2 && spec[0] > 0 && spec[1] > 0
                return [v:true] + spec
            endif

            if spec != v:false
                echohl WarningMsg
                echomsg 'vim-myspace: invalid spec for '
                    \ . string(key)
                    \ . ': expected false (0) or [from: int > 0, to: int > 0], got: ' . string(spec)
                echohl None
            endif

            break
        endif
    endfor

    return [v:false, 0, 0]
endfunction

" after loading a file, rewrite the community standard to our preferred indentation
function s:MySpaceAfterLoad()
    if s:IsDisabled()
        return
    endif

    let [match, from, to] = s:Lookup(&filetype)

    if match
        let save_view = winsaveview()
        silent! %substitute/\v^( +)/\=s:Replace(submatch(0), from, to)/e
        call winrestview(save_view)
    endif
endfunction

" before saving a file, rewrite our indentation to the community standard
function s:MySpaceBeforeSave()
    if s:IsDisabled()
        return
    endif

    let [match, from, to] = s:Lookup(&filetype)

    if match
        let save_view = winsaveview()
        silent! %substitute/\v^( +)/\=s:Replace(submatch(0), to, from)/e
        call winrestview(save_view)
    endif
endfunction

" after saving a file, undo the substitution so it doesn't
" clutter the undo stack
function s:MySpaceAfterSave()
    if s:IsDisabled()
        return
    endif

    let [match, from, to] = s:Lookup(&filetype)

    if match
        let save_view = winsaveview()
        silent normal! u
        call winrestview(save_view)
    endif
endfunction

augroup MySpace
    au!
    au BufReadPost  * call s:MySpaceAfterLoad()
    au BufWritePre  * call s:MySpaceBeforeSave()
    au BufWritePost * call s:MySpaceAfterSave()
augroup END
