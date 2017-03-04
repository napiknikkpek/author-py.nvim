
if !exists('s:path')
  let s:path = []
  let s:tags = $HOME . '/.config/nvim/tags/tags-py'
endif

fu! author#py#options#generate_tags()
  let cmd = printf(
        \ 'ctags --language-force=Python -R -f %s %s',
        \ s:tags, join(s:path, ' '))
  call system(cmd)
endfu

fu! author#py#options#get_path()
py3 << EOF
import vim
import sys
import os
path = sys.path
if 'PYTHONPATH' in os.environ:
    path += os.environ['PYTHONPATH'].split(':')
vim.command('let s:path = {}'.format(path))
EOF
  return join(s:path, ',')
endfu

fu! author#py#options#get_tags()
  return s:tags
endfu
