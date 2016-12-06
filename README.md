# vim-myspace

Four spaces good, two spaces bad!

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [SYNOPSIS](#synopsis)
- [INSTALL](#install)
  - [Pathogen](#pathogen)
  - [vim-plug](#vim-plug)
  - [Vundle](#vundle)
- [DESCRIPTION](#description)
  - [Why?](#why)
- [CONFIG](#config)
- [CAVEATS](#caveats)
  - [Preformatted Sections](#preformatted-sections)
    - [before](#before)
    - [after](#after)
- [FAQ](#faq)
  - [I prefer 2 spaces. Can I use this plugin to view/edit 4-space files with 2 spaces?](#i-prefer-2-spaces-can-i-use-this-plugin-to-viewedit-4-space-files-with-2-spaces)
- [SEE ALSO](#see-also)
- [VERSION](#version)
- [AUTHOR](#author)
- [COPYRIGHT AND LICENSE](#copyright-and-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## SYNOPSIS

```vim
" display/edit these 2-spaced filetypes with 4 spaces (my preference), but save them
" with 2 spaces (community standard)
let g:myspace_filetypes = { 'coffee|crystal|ruby|scala|swift': [ 2, 4 ] }
```

## INSTALL

### [Pathogen](https://github.com/tpope/vim-pathogen)

    $ git clone https://github.com/chocolateboy/vim-myspace ~/.vim/bundle/vim-myspace

### [vim-plug](https://github.com/junegunn/vim-plug)

Add `Plug 'chocolateboy/vim-myspace'` to your `~/.vimrc` and run `PlugInstall`.

### [Vundle](https://github.com/gmarik/Vundle.vim)

Add `Plugin 'chocolateboy/vim-myspace'` to your `~/.vimrc` and run `PluginInstall`.

## DESCRIPTION

vim-myspace is a vim plugin which allows files to be edited and viewed with your preferred
indentation level (e.g. 4 spaces) but transparently saved with the default/community-standard
indentation level (e.g. 2 spaces).

### Why?

I find 2 spaces cramped and painful to read, but the community has settled on this standard for
various languages, including:

* CoffeeScript
* Crystal
* Ruby
* Scala
* Swift

Rather than fruitlessly attempting to overthrow the status quo, this plugin allows you to
view and edit files in your preferred style, while saving and shipping them in the style
stipulated by a project, workplace, community &c.

## CONFIG

Currently, the only setting is `g:myspace_filetypes`, which should be assigned a dictionary whose
keys are filetypes and whose values are dictionaries of options.

Indentations spanning multiples of `from` spaces are translated to corresponding
multiples of `to` spaces.

The filetypes → [ from, to ] mapping can be specified individually e.g.:

```vim
let g:myspace_filetypes = {
     \ 'coffee':  [ 2, 4 ],
     \ 'crystal': [ 2, 4 ],
     \ 'ruby':    [ 2, 4 ],
     \ 'scala':   [ 2, 4 ],
     \ 'swift':   [ 2, 4 ],
     \ }
```

Or, if multiple filetypes share the same rewrite rule, they can be specified together separated by
a pipe character:

```vim
let g:myspace_filetypes = {
    \ 'coffee|crystal|ruby|scala|swift': [ 2, 4 ],
    \ 'ada':                             [ 3, 4 ]
    \ }
```

## CAVEATS

The plugin only operates on lines that begin with spaces. Lines that begin with tabs are unaffected.
Lines that begin with spaces followed by one or more tabs are only transformed up to the tab(s).

You may need to tweak the indentation settings in your `~/.vimrc` to reflect your preferred style.
Auto-indentation (i.e. while typing) works as expected for me with the following `~/.vimrc` settings:

```vim
set tabstop=8
set softtabstop=4
set shiftwidth=4
set noexpandtab
```

### Preformatted Sections

The transform may occasionally affect indentation on lines that are already correctly indented
such as the bodies of multi-line comments or here-docs e.g.:

#### before

```ruby
code = <<EOS # four spaces
class Foo {
    foo() {
        return 42
    }
}
EOS
```

#### after

```ruby
code = <<EOS # eight spaces
class Foo {
        foo() {
                return 42
        }
}
EOS
```

## FAQ

### I prefer 2 spaces. Can I use this plugin to view/edit 4-space files with 2 spaces?

Yes and no. While well-formed indents can be correctly mapped in both directions e.g.:

    0 ->  0
    2 ->  4
    4 ->  8
    6 -> 12

    0 ->  0
    4 ->  2
    8 ->  4
   12 ->  6

\- real-world code contains ill-formed indents i.e. 4-spaced files with lines that
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
    /*******              // 0
     * this is a comment  // 1
     */                   // 1
```

Mapping 2 spaces to 4 spaces is reversible i.e. there is no loss of
information about the original number of spaces when that number is doubled:

    1 -> 2
    2 -> 4
    3 -> 6
    4 -> 8

However, *reducing* the number of spaces may be lossy i.e.:

    1 -> ?
    2 -> 1
    3 -> ?
    4 -> 2

XXX seems to work OK with 4 -> 2

XXX this may not be an issue if we ignore spaces < `from` e.g. in the above
example, we leave 1, 2, 3

## SEE ALSO

* [AutoAdapt](http://www.vim.org/scripts/script.php?script_id=4654) - automatically update timestamps, copyright notices, etc.
* [detectindent](https://github.com/ciaranm/detectindent) - vim script for automatically detecting indent settings
* [GitHub: better-sized tabs in code](https://userstyles.org/styles/70979/github-better-sized-tabs-in-code)

## VERSION

0.0.1

## AUTHOR

[chocolateboy](mailto:chocolate@cpan.org)

## COPYRIGHT AND LICENSE

Copyright © 2016-2017 by chocolateboy

vim-myspace is free software; you can redistribute it and/or modify it under the
terms of the [Artistic License 2.0](http://www.opensource.org/licenses/artistic-license-2.0.php).
