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

" Blog Header Syntax (it's YAML, but I wanted to limit / customize it)
syn keyword blogHeaderKeywords title japTitle nextgroup=blogHeaderStringDelimitter contained
syn keyword blogHeaderKeywords date nextgroup=blogHeaderDateDelimitter contained
syn keyword blogHeaderKeywords tags categories nextgroup=blogHeaderListDelimitter contained
syn match blogHeaderStringDelimitter ':' nextgroup=blogHeaderString skipwhite contained
syn match blogHeaderListDelimitter ':' nextgroup=blogHeaderList skipwhite contained
syn match blogHeaderDateDelimitter ':' nextgroup=blogHeaderDate skipwhite contained
syn match blogHeaderString '\w\+' contained
syn match blogHeaderDate '\d\{4}-\d\{2}-\d\{2} \d\{2}:\d\{2} +\d\{2}:\=\d\{2}' contained
syn match blogHeaderListDelimitter ',' contained
syn region blogHeaderList start="\[" end="\]" contains=blogHeaderString,blogHeaderListDelimitter
syn region blogHeaderBlock start="^---$" end="^---$" contains=blogHeaderKeywords transparent fold

let b:current_syntax = "blog"
hi def link blogHeaderString   Constant 
hi def link blogHeaderDate     Constant
hi def link blogHeaderKeywords Type

" Functions
let s:current_file = expand('<sfile>')
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
		let l:seqno = matchstr(l:file, '_\(\d\+\)')
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
	let l:currentPath = expand('<sfile>:p:h')
	let l:imgDir = l:currentPath . '/images/'
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

command Timestamp :call UpdateTimestamps()
command UpdateDates :call ToggleUpdateDates()

au BufWrite <buffer> :silent! call SaveFile()

echom "Run :UpdateDates to enable date updating."

" Clean up if we came from a rename operation

" Other settings
syn sync fromstart
setlocal spell ts=2 sts=2 sw=2 et
let b:updatedates=0
