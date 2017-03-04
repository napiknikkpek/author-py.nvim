import neovim
import pyflakes.api


class Collector:
    def __init__(self, bufnr):
        self.bufnr = bufnr
        self.data = []

    def unexpectedError(self, filename, msg):
        pass

    def syntaxError(self, filename, msg, lineno, offset, text):
        item = {}
        item['bufnr'] = self.bufnr
        item['filename'] = filename
        item['lnum'] = lineno
        item['col'] = offset + 1
        item['text'] = msg + '\n' + text
        item['type'] = 'E'
        self.data.append(item)

    def flake(self, obj):
        item = {}
        item['bufnr'] = self.bufnr
        item['filename'] = obj.filename
        item['lnum'] = obj.lineno
        item['col'] = obj.col + 1
        item['text'] = (obj.message % obj.message_args)
        item['type'] = 'W'
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
