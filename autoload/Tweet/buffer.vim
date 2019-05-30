function! Tweet#buffer#new(bufname, content) abort
    execute 'vnew' fnameescape(a:bufname)
    setlocal modifiable
    silent %delete _
    call setline(1, a:content)
    setlocal nomodified nomodifiable
    setlocal buftype=nofile bufhidden=wipe
endfunction
