
if !exists('s:timers')
  let s:timers = {}
endif

call _author_py_init()

fu! author#py#timer_callback(tid)
  let tm = s:timers[a:tid]
  let btick = getbufvar(tm.bfn, 'changedtick')
  if tm.tick < btick
    let tm.tick = btick
    return
  endif
  call timer_stop(a:tid)
  unlet s:timers[a:tid]
  call rpcnotify(g:author#py#_channel_id, 'check', tm.bfn, tm.tick)
  call author#py#register_events(tm.bfn)
endfu

fu! s:delete_event(bfn)
  exe printf("au! * <buffer=%s>", a:bfn)
endfu

fu! s:add_event(bfn)
  exe printf(
        \ "au TextChanged,TextChangedI <buffer=%s> ".
        \ "call author#py#process_event()",
        \ a:bfn)
endfu

fu! author#py#register_events(bfn)
  call s:delete_event(a:bfn)
  call s:add_event(a:bfn)
endfu

fu! author#py#process_event()
  let bfn = bufnr('%')
  call s:delete_event(bfn)
  let id = timer_start(400, 'author#py#timer_callback', {'repeat': -1})
  let tm = {}
  let tm.bfn = bfn
  let tm.tick = b:changedtick
  let s:timers[id] = tm
endfu

fu! author#py#populate(bfn, tick, data)
  if bufnr('%') != a:bfn || b:changedtick > a:tick
    return
  endif
  if exists('b:error_src')
    call nvim_buf_clear_highlight(a:bfn, b:error_src, 0, -1)
  endif

  let src = 0
  for elem in a:data
    let line = elem['lnum'] - 1
    let column = elem['col'] - 1
    let b = min([column, len(getline(line + 1)) - 1])
    let e = b + 1
    let group = elem['type'] == 'E' ? 'Error' : 'Todo'
    let src = nvim_buf_add_highlight(a:bfn, src, group, line, b, e)
  endfor

  let b:error_src = src
  call setqflist(a:data, 'r')
endfu
