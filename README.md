# vim-myspace

Four spaces good, two spaces bad!

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [NAME](#name)
- [INSTALLATION](#installation)
  - [Pathogen](#pathogen)
  - [vim-plug](#vim-plug)
  - [Vundle](#vundle)
- [SYNOPSIS](#synopsis)
- [DESCRIPTION](#description)
  - [Why?](#why)
- [SETTINGS](#settings)
  - [myspace_filetype](#myspace_filetype)
  - [myspace_disable](#myspace_disable)
- [TIPS & TRICKS](#tips--tricks)
  - [Project-Specific Settings](#project-specific-settings)
  - [Auto-Indentation](#auto-indentation)
- [CAVEATS](#caveats)
  - [Tabs](#tabs)
  - [Preformatted Sections](#preformatted-sections)
- [FAQ](#faq)
  - [I prefer 2 spaces. Can I use this plugin to view/edit 4-space files with 2 spaces?](#i-prefer-2-spaces-can-i-use-this-plugin-to-viewedit-4-space-files-with-2-spaces)
- [SEE ALSO](#see-also)
- [VERSION](#version)
- [AUTHOR](#author)
- [COPYRIGHT AND LICENSE](#copyright-and-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# NAME

vim-myspace - safely view and edit files with your preferred indentation style

# INSTALLATION

## [Pathogen](https://github.com/tpope/vim-pathogen)

    $ git clone https://github.com/chocolateboy/vim-myspace ~/.vim/bundle/vim-myspace

## [vim-plug](https://github.com/junegunn/vim-plug)

Add `Plug 'chocolateboy/vim-myspace'` to your `~/.vimrc` and run `PlugInstall`.

## [Vundle](https://github.com/gmarik/Vundle.vim)

Add `Plugin 'chocolateboy/vim-myspace'` to your `~/.vimrc` and run `PluginInstall`.

# SYNOPSIS

```vim
" safely view and edit these 2-spaced filetypes (community standard) with 4 spaces (my preference)
let g:myspace_filetype = { 'crystal|ruby|scala|swift': [2, 4] }
```

# DESCRIPTION

vim-myspace is a vim plugin which allows files to be viewed and edited with your preferred
indentation style (e.g. 4 spaces) but transparently saved with the default/community-standard
style (e.g. 2 spaces).

## Why?

I find 2 spaces cramped and painful to read, but the community has settled on this standard for
various languages, including:

* Crystal
* Ruby
* Scala
* Swift
* YAML

Rather than fruitlessly attempting to overthrow the status quo, this plugin allows you to
view and edit files in your preferred style, while saving and shipping them in the style
stipulated by a project, workplace, community etc.

# SETTINGS

## myspace_filetype

The plugin is configured by assigning a dictionary of mappings to `g:myspace_filetype`
(global) or `b:myspace_filetype` (buffer-local). If defined, the buffer-local mappings
take precedence over the global mappings.

> `~/.vimrc`

```vim
let g:myspace_filetype = { 'crystal|ruby|scala|swift': [2, 4] }
```

The dictionary's keys are [filetypes](http://vimdoc.sourceforge.net/htmldoc/filetype.html)
(strings) and its values are either `from` → `to` pairs (arrays), or false (0) to disable
rewriting for the type(s). Indentations spanning multiple `from` spaces are translated
to the corresponding number of `to` spaces when files with the specified type are loaded,
and unmapped (`to` → `from`) and remapped (`from` → `to`) before and after the
files are saved. Remainders are passed through unchanged in both directions, e.g.
for 2 → 4:

| from  | to    | back |
| ----- | ----- | ---: |
| 2     | 4     | 2    |
| 3     | 5     | 3    |
| 4     | 8     | 4    |
| 5     | 9     | 5    |

The mapping from filetypes to `from`/`to` pairs can be specified individually e.g.:

```vim
let g:myspace_filetype = {
    \ 'crystal': [2, 4],
    \ 'ruby':    [2, 4],
    \ 'scala':   [2, 4],
    \ 'swift':   [2, 4],
    \ }
```

Or, if multiple filetypes share the same rewrite rule, they can be specified together,
separated by a pipe character:

```vim
let g:myspace_filetype = {
    \ 'crystal|ruby|scala|swift': [2, 4],
    \ 'ada':                      [3, 4],
    \ }
```

## myspace_disable

The plugin can be disabled by setting `g:myspace_disable` (global) or `b:myspace_disable` (buffer-local)
to true (1) e.g.:

```vim
let b:myspace_disable = 1
```

# TIPS & TRICKS

## Project-Specific Settings

Indentation can be configured on a per-project basis by defining
[directory-specific autocommands](https://til.hashrocket.com/posts/720a6a05f9-matching-on-directories-for-vims-autocmd),
which either:

* (re-)define mappings:

    ```vim
    autocmd BufNewFile,BufRead ~/build/example/*.js let b:myspace_filetype = { 'javascript': [2, 4] }
    ```

* disable rewrites for files that already use your preferred style:

    ```vim
    autocmd BufNewFile,BufRead ~/build/example/* let b:myspace_disable = 1
    ```

* or a combination of the two:

    ```vim
    " default settings: expand 2-space TypeScript to 4 spaces
    let g:myspace_filetype = { 'typescript': [2, 4] }

    " custom settings for a project with 2-space JavaScript (expand) and 4-space
    " TypeScript (no change)
    autocmd BufNewFile,BufRead ~/build/example/* let b:myspace_filetype = { 'javascript': [2, 4], 'typescript': 0 }
    ```

Since overrides are typically buffer-local, they can be sourced from
a (shared) file without affecting the global settings e.g:

> `~/.vim/local/indent-js-24.vim`

```bash
let b:myspace_filetype = { 'javascript': [2, 4] }
```

> `~/.vimrc`

```vim
autocmd BufNewFile,BufRead ~/code/example/*.js source ~/.vim/local/indent-js-24.vim
```

## Auto-Indentation

You may need to tweak the indentation settings in your `~/.vimrc` to reflect your preferred style.
Automatic indentation (i.e. while typing) works as expected for me with the following `~/.vimrc` settings:

```vim
set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=8
```

In addition, you may need to add overrides for core and third-party filetype plugins
which impose an indentation style:

```vim
" override the 2-space indentation imposed by vim-ruby
" https://github.com/vim-ruby/vim-ruby/issues/234
autocmd FileType ruby :setlocal expandtab shiftwidth=4 tabstop=4
```

Alternatively, it may be possible to toggle a plugin's indentation settings on/off via a variable e.g.:

```vim
" disable the 2-space indentation imposed by vim-ruby's filetype plugin
let g:ruby_recommended_style = 0
```

# CAVEATS

## Tabs

The plugin only operates on lines that begin with spaces. Lines that begin with tabs are unaffected.
Lines that begin with spaces followed by one or more tabs are only transformed up to the tab(s).

## Preformatted Sections

The transform may occasionally affect indentation on lines that are already correctly indented
such as the bodies of multi-line comments or heredocs e.g.:

**before**

```ruby
code = <<EOS # four spaces
class Foo {
    foo() {
        return 42
    }
}
EOS
```

**after**

```ruby
code = <<EOS # eight spaces
class Foo {
        foo() {
                return 42
        }
}
EOS
```

# FAQ

## I prefer 2 spaces. Can I use this plugin to view/edit 4-space files with 2 spaces?

Yes and no. While well-formed indents can correctly be roundtripped e.g. for 4 → 2:

| from   | to   | back   |
| -----: | ---: | -----: |
| 4      | 2    | 4      |
| 8      | 4    | 8      |
| 12     | 6    | 12     |
| 16     | 8    | 16     |

\- real-world code contains ill-formed indents e.g. 4-spaced files with lines that
begin with, say, 6 spaces:

```cpp
    if (::v8::internal::FLAG_trace_sim) {                //  4
      PrintF("Call to host function at %p args %08x\n",  //  6 (!)
          reinterpret_cast<void*>(external), arg0);      // 10 (!)
    }                                                    //  4
```

\- or lines that begin with an odd number of spaces:

```javascript
    if (                                                 //  4
           (await Fs.exists(cachedPath))                 // 11 (!)
        && (cached = await Fs.readFile(cachedPath))      //  8
    ) {                                                  //  4
        request = Promise.resolve(cached)                //  8
    }                                                    //  4
```

```cpp
    /*******              // 4
     * this is a comment  // 5
     */                   // 5
```

Expansion is always reversible i.e. if `from` <= `to`, there is no loss of
information about the original number of spaces when multiples of `from`
are mapped to multiples of `to`. The same is not always true if `from` >
`to` e.g. for 4 → 2:

| from   | to   | back   |
| -----: | ---: | -----: |
| 2      | 2    | 4      |
| 3      | 3    | 5      |
| 6      | 4    | 8      |
| 7      | 5    | 9      |

# SEE ALSO

* [AutoAdapt](http://www.vim.org/scripts/script.php?script_id=4654) - automatically update timestamps, copyright notices, etc.
* [detectindent](https://github.com/ciaranm/detectindent) - vim script for automatically detecting indent settings
* [GitHub: better-sized tabs in code](https://userstyles.org/styles/70979/github-better-sized-tabs-in-code) - a userstyle which displays tabs on GitHub as 4 spaces rather than 8
* [sleuth.vim](https://github.com/tpope/vim-sleuth) - heuristically set indentation options

# VERSION

0.1.3

# AUTHOR

[chocolateboy](mailto:chocolate@cpan.org)

# COPYRIGHT AND LICENSE

Copyright © 2016-2018 by chocolateboy

vim-myspace is free software; you can redistribute it and/or modify it under the
terms of the [Artistic License 2.0](http://www.opensource.org/licenses/artistic-license-2.0.php).
