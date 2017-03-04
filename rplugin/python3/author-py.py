import neovim
import pyflakes.api


class Collector:
    def __init__(self, bufnr):
        self.bufnr = bufnr
        self.data = []

    def unexpectedError(self, filename, msg):
        pass

    def syntaxError(self, filename, msg, lineno, offset, text):
        item = {
            'bufnr': self.bufnr,
            'filename': filename,
            'lnum': lineno,
            'text': msg,
            'type': 'E'
        }
        if offset is not None:
            item['col'] = offset + 1
        self.data.append(item)

    def flake(self, obj):
        item = {
            'bufnr': self.bufnr,
            'filename': obj.filename,
            'lnum': obj.lineno,
            'col': obj.col + 1,
            'text': (obj.message % obj.message_args),
            'type': 'W'
        }
        self.data.append(item)


@neovim.plugin
class AuthorPy:
    def __init__(self, vim):
        self.vim = vim

    @neovim.function("_author_py_init", sync=True)
    def init_author_py(self, args):
        self.vim.vars["author#py#_channel_id"] = self.vim.channel_id

    @neovim.rpc_export('check')
    def check(self, bufnr, tick):
        collector = Collector(bufnr)
        buf = self.vim.buffers[bufnr]
        text = '\n'.join(buf)
        pyflakes.api.check(text, buf.name, collector)
        self.vim.call('author#py#populate', bufnr, tick, collector.data)
