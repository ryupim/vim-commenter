" g:commenter#comment_str が存在するなら1を返す
function! g:commenter#HasCommentStr()
  if exists('g:commenter#comment_str')
    return 1
  endif
  echom "vim-commenter doesn't work for filetype " . &ft . " yet"
  return 0
endfunction


" 範囲行に対して最も小さいインデントを得る
function! g:commenter#DetectMinIndent(start, end)
  let l:min_indent = -1
  let l:i = a:start
  while l:i <= a:end
    if l:min_indent == -1 || indent(l:i) < l:min_indent
      let l:min_indent = indent(l:i)
    endif
    let l:i +=1
  endwhile
  return l:min_indent
endfunction

function! g:commenter#InsertOrRemoveComment(lnum, line, indent, is_insert)
  " インデントがないケースに対応
  let l:prefix = a:indent > 0 ? a:line[:a:indent - 1] : ''
  if a:is_insert
    call setline(a:lnum, l:prefix . g:commenter#comment_str .
          \ a:line[a:indent:])
  else
    call setline(
          \ a:lnum, l:prefix . a:line[a:indent + len(g:commenter#comment_str):])
  endif
endfunction


"現在行をコメントアウトする（Pythonスタイル）
function! g:commenter#ToggleComment(count)
  if !g:commenter#HasCommentStr()
    return
  endif
  let l:start = line('.')
  let l:end = l:start + a:count - 1
  if l:end > line('$') " ファイルの最終行以降を処理しない　
    let l:end = line('$')
  endif
  let l:indent = g:commenter#DetectMinIndent(l:start, l:end)
  let l:lines = l:start == l:end ? [getline(l:start)] : getline(l:start, l:end)
  let l:cur_row = getcurpos()[1]
  let l:cur_col = getcurpos()[2]
  let l:lnum = l:start
  if l:lines[0][l:indent:l:indent + len(g:commenter#comment_str) - 1] == g:commenter#comment_str
    let l:is_insert = 0
    let l:cur_offset = -len(g:commenter#comment_str)
  else
    let l:is_insert = 1
    let l:cur_offset = len(g:commenter#comment_str)
  endif
  echo l:lines
  for l:line in l:lines
    call g:commenter#InsertOrRemoveComment(
          \ l:lnum, l:line, l:indent, l:is_insert)
    let l:lnum += 1
  endfor
  call cursor(l:cur_row, l:cur_col + l:cur_offset)
endfunction
