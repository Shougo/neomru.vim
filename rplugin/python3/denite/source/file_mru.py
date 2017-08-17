# ============================================================================
# FILE: file_mru.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
# License: MIT license
# ============================================================================

from .base import Base
from denite.util import relpath


class Source(Base):

    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'file_mru'
        self.kind = 'file'
        self.sorters = []

    def gather_candidates(self, context):
        return [{
            'word': x,
            'abbr': self.vim.call('neomru#_abbr', relpath(self.vim, x)),
            'action__path': x
        } for x in self.vim.eval(
            'neomru#_get_mrus().file.'
            +'gather_candidates([], {"is_redraw": 0})')]
