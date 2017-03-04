
call author#py#process_event()

let &l:makeprg = 'pyflakes %'
let &l:path = author#py#options#get_path()
" let &l:tags = author#py#get_tags()
