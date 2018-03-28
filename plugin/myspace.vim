" XXX doesn't ignore non-code (e.g. HEREDOCS)
" XXX probably doesn't work with folds
" TODO investigate removing the search pattern from history as per the SO answer
" for winsaveview/winrestview, see: http://stackoverflow.com/a/23650554
" see also: AutoAdapt: http://www.vim.org/scripts/script.php?script_id=4654

if exists('g:myspace_loaded')
    finish
end

let g:myspace_loaded = v:true

if !exists('g:myspace')
    let g:myspace = {}
endif

" expand or contract the supplied space prefix, mapping multiples of `from` spaces
" to the corresponding number of `to` spaces
function s:MySpace_replace(match, from, to)
    let quotient = strlen(a:match) / a:from
    let remainder = strlen(a:match) % a:from
    return repeat(' ', a:to * quotient + remainder)
endfunction

" signature: language: string → [registered: boolean, from: integer, to: integer]
"
" given a language, return a [boolean, from, to] triple.
" if no mapping is registered for the language, the boolean is false.
" otherwise, it's true and `from` and `to` are set to their configured values.
function s:MySpace_lookup(lang)
    for key in keys(g:myspace)
        let spec = g:myspace[key]

        if type(spec) == v:t_list && len(spec) == 2 && spec[0] > 0 && spec[1] > 0
            let langs = split(key, '|')

            if index(langs, a:lang) >= 0
                return [v:true] + spec
            endif
        else
            echohl WarningMsg
            echomsg 'vim-myspace: invalid spec for '
                \ . string(key)
                \ . ': expected [from: int >= 0, to: int >= 0], got: ' . string(spec)
            echohl None
        end
    endfor

    return [v:false, 0, 0]
endfunction

" after loading a file, rewrite the community standard to our preferred spacing
function s:MySpaceAfterLoad()
    let [match, from, to] = s:MySpace_lookup(&filetype)

    if match
        let save_view = winsaveview()
        silent! %substitute/\v^( +)/\=s:MySpace_replace(submatch(0), from, to)/e
        call winrestview(save_view)
    endif
endfunction

" before saving a file, rewrite our spacing to the community standard
function s:MySpaceBeforeSave()
    let [match, from, to] = s:MySpace_lookup(&filetype)

    if match
        let save_view = winsaveview()
        silent! %substitute/\v^( +)/\=s:MySpace_replace(submatch(0), to, from)/e
        call winrestview(save_view)
    endif
endfunction

" after saving a file, undo the substitution so it doesn't
" clutter the user's undo stack
function s:MySpaceAfterSave()
    let [match, from, to] = s:MySpace_lookup(&filetype)

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
