" VIM files to make blog post editing slightly easier.
" Include with :so editor.vim

" The file is by default, Markdown.
runtime! syntax/markdown.vim
unlet b:current_syntax
let b:current_syntax = "markdown"

" Highlight C
unlet b:current_syntax
syntax include @C syntax/c.vim
syntax region cSnippet start='```c' end='```' keepend contains=@C

" Highlight C++
unlet b:current_syntax
syntax include @CPP syntax/cpp.vim
syntax region cppSnippet start='```cpp' end='```' contains=@CPP keepend

" Highlight JavaScript
unlet b:current_syntax
syntax include @JAVASCRIPT syntax/javascript.vim
syntax region jsSnippet start='```js' end='```' contains=@JAVASCRIPT keepend

" Highlight Python
unlet b:current_syntax
syntax include @PYTHON syntax/python.vim
syntax region pythonSnippet start='```python' end='```' contains=@PYTHON keepend

" Highlight Dockerfiles
unlet b:current_syntax
syntax include @DOCKERFILE syntax/dockerfile.vim
syntax region dockerSnippet start='```dockerfile' end='```' contains=@DOCKERFILE keepend

" Highlight YML
unlet b:current_syntax
syntax include @YAML syntax/yaml.vim
syntax region yamlSnippet start='```yaml' end='```' contains=@YAML keepend

" Highlight Bash
unlet b:current_syntax
syntax include @BASH syntax/sh.vim
syntax region bashSnippet start='```bash' end='```' contains=@BASH keepend
syntax region shSnippet start='```sh' end='```' contains=@BASH keepend

" Blog Header Syntax (it's YAML, but I wanted to limit / customize it)
syn keyword blogHeaderKeywords title japTitle published nextgroup=blogHeaderStringDelimitter contained
syn keyword blogHeaderKeywords date nextgroup=blogHeaderDateDelimitter contained
syn keyword blogHeaderKeywords tags categories nextgroup=blogHeaderListDelimitter contained
syn keyword blogHeaderKeywords rating nextgroup=blogHeaderNumberDelimitter contained
syn keyword blogHeaderKeywords image nextgroup=blogHeaderURLDelimitter contained
syn match blogHeaderStringDelimitter ':' nextgroup=blogHeaderString skipwhite contained
syn match blogHeaderURLDelimitter ':' nextgroup=blogHeaderURL skipwhite contained
syn match blogHeaderListDelimitter ':' nextgroup=blogHeaderList skipwhite contained
syn match blogHeaderDateDelimitter ':' nextgroup=blogHeaderDate skipwhite contained
syn match blogHeaderNumberDelimitter ':' nextgroup=blogHeaderNumber skipwhite contained
syn match blogHeaderNumber '\d\+' contained
syn match blogHeaderString '.\+\n' contained
syn match blogHeaderStringEnclosed '\(\w\|\s\)\+' contained
syn match blogHeaderDate '\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2} +\d\{2}:\=\d\{2}' contained
syn match blogHeaderURL /https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*/ contained
syn match blogHeaderListDelimitter ',' contained
syn region blogHeaderList start="\[" end="\]" contains=blogHeaderStringEnclosed,blogHeaderListDelimitter contained
syn region blogHeaderBlock start="^---$" end="^---$" contains=blogHeaderKeywords transparent fold
syn cluster @NoSpell add=blogHeaderString,blogHeaderURL
syn iskeyword @,48-57,_,192-255,$,-

let b:current_syntax = "blog"
hi def link blogHeaderString         Constant 
hi def link blogHeaderStringEnclosed Constant
hi def link blogHeaderURL            Constant 
hi def link blogHeaderNumber         Constant
hi def link blogHeaderDate           Constant
hi def link blogHeaderKeywords       Type
hi SpellBad ctermfg=white ctermbg=red cterm=underline guifg=red guibg=white gui=underline

" Functions
let s:current_file = expand('<sfile>')
let s:current_dir = expand('<sfile>:p:h')
function! GetAllUsedImgFiles()
	let l:cursorpos = getcurpos()
	let l:result = search('<img.\+src\s*=\s*\"\/images\/', 'c', line('$'))
	let l:imgFiles = []
	while l:result != 0
		let l:preimgpos = getcurpos()
		let l:innerResult = search('\d\{8}_\d\+.\w', 'c', line('$'))
		if l:innerResult != 0
			let l:linewithimg = getline(l:innerResult)
			let l:file = matchlist(l:linewithimg, '\(\d\{8}\)_\(\d\+\).\(\w\+\)')
			let l:imgFiles += [l:file]
		endif
		call setpos('.', l:preimgpos)
		let l:result = search('<img.\+src\s*=\s*\"\/images\/', '', line('$'))
	endwhile
	call setpos('.', l:cursorpos)
	return l:imgFiles
endfunction

function! GetNextAvailableSeqNo(dir, prefix)
	let l:files = readdir(a:dir, {n -> n =~ a:prefix})
	let l:highestseqno = 0
	for l:file in l:files
		let l:seqno = str2nr(matchlist(l:file, '_\(\d\+\)')[1])
		if l:seqno > l:highestseqno
			let l:highestseqno = l:seqno
		endif
	endfor
	return l:highestseqno + 1
endfunction

function! UpdateTimestamps()
	" will attempt to update blog post timestamps, including for images.
	let l:headerTs = strftime("%Y-%m-%d %H:%M %z")
	let l:filePrefix = strftime("%Y%m%d_")
	let l:cursorpos = getcurpos()

	" update date in header
	call cursor(1, 1)
	let l:result = search("date:", "c", line('$'))
	if l:result != 0
		call setline(line("."), "date: " . l:headerTs)
	endif

	" update ts for all the img files defined in blog post
	let l:imgDir = s:current_dir . '/images/'
	let l:imgFiles = GetAllUsedImgFiles()
	let l:seqno = GetNextAvailableSeqNo(l:imgDir, l:filePrefix)

	call cursor(1, 1)
	for l:imgFile in l:imgFiles
		if l:imgFile[1] . '_' == l:filePrefix
			continue
		endif

		let l:tempExpr = l:filePrefix . l:seqno
		call rename(l:imgDir . l:imgFile[0], l:imgDir . l:tempExpr . '.' . l:imgFile[3])
		execute '%s/' . l:imgFile[1] . '_' . l:imgFile[2] . '/' . l:tempExpr . '/'
		let l:seqno += 1
	endfor

	" set cursor back to normal
	call setpos('.', l:cursorpos)
endfunction

function SaveFile()
	if b:updatedates
		" if this is a dated file, update the date there.
		let l:currName = expand('%:p')
		let l:dateNow = strftime('%Y-%m-%d')
		let l:dateMatch = matchstr(l:currName, '\d\{4}-\d\{2}-\d\{2}')
		if l:dateMatch != "" && l:dateMatch != l:dateNow
			let l:newName = substitute(l:currName, '\d\{4}-\d\{2}-\d\{2}', l:dateNow, 'g')
			call UpdateTimestamps()
			execute 'w! ' . l:newName
			execute 'e! '. l:newName
			call delete(l:currName)
			return
		else
			call UpdateTimestamps()
		endif
	endif
endfunction

function ToggleUpdateDates()
	let b:updatedates = !b:updatedates
	if b:updatedates
		echom "Set to update dates."
	else
		echom "Do not update dates."
	endif
endfunction

function InsertImage(imgPath)
	let l:filePrefix = strftime("%Y%m%d_")
	let l:imgDir = s:current_dir . '/images/'
	let l:fileext = matchstr(a:imgPath, '\.\(\w\+\)')
	let l:nextSeqNo = GetNextAvailableSeqNo(l:imgDir, l:filePrefix)
	echom l:nextSeqNo

	call rename(a:imgPath, l:imgDir . l:filePrefix . l:nextSeqNo  . l:fileext)
	call append('.', '<p class="text-center text-gray lh-condensed-ultra f6">%%</p>')
	call append('.', '<img src="/images/' . l:filePrefix . l:nextSeqNo . l:fileext . '" style="max-width: 400px; width: 100%; margin: 0 auto; display: block;" alt="%%"/>')
endfunction

function InsertHeader()
	call append(0, ['---', 'title:', 'date:', 'published: true', '---'])
endfunction

function InsertAnimeHeader()
	call append(0, ['---', 'title:', 'japTitle:', 'date:', 'image:', 'rating:', '---'])
endfunction


command Timestamp :call UpdateTimestamps()
command UpdateDates :call ToggleUpdateDates()
command -nargs=1 -complete=file InsertImage call InsertImage(<f-args>)
command InsertHeader :call InsertHeader()
command InsertAnimeHeader :call InsertAnimeHeader()

au BufWrite <buffer> :silent! call SaveFile()

echom "Run :UpdateDates to enable date updating."

" Clean up if we came from a rename operation

" Other settings
syn sync fromstart
setlocal spell ts=2 sts=2 sw=2 et
let b:updatedates=0
