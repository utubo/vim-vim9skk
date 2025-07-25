vim9script

var default = {
  jisyo: ['~/SKK-JISYO.L:EUC-JP', '~/SKK-JISYO.*.utf8:UTF8'],
  jisyo_user: '~/VIM9SKK-JISYO.user',
  jisyo_recent: '~/VIM9SKK-JISYO.recent',
  recent: 1000,
  parens: ['（）', '〔〕', '［］', '｛｝', '〈〉', '《》', '「」', '『』', '【】'],
  marker_okuri: '*',
  mode_label: {
    off: '_A',
    hira: 'あ',
    kata: 'ア',
    hankaku: 'ｶﾅ',
    alphabet: 'Ａ',
    abbr: 'ab',
    midasi: '▽',
  },
  mode_label_timeout: 1000,
  popup_minheight: 5,
  popup_maxheight: 20,
  search_limit: 100,
  keymap: {
    enable: '',
    disable: '',
    toggle: '<C-j>',
    kata: 'q',
    hankaku: '<C-q>',
    alphabet: 'L',
    abbr: '/',
    midasi: 'Q',
    midasi_toggle: [],
    select: '<Space>',
    next: '<Tab>',
    prev: ['<S-Tab>', 'x'],
    select_top: [],
    complete: '<CR>',
    cancel: '<C-g>',
    delete: '<C-d>',
    prefix: '>',
    insert_leave: '<Esc>',
  },
  roman_table: {},
  change_popuppos: vim9skk#NoChangePopupPos,
  run_on_midasi: false,
}
g:vim9skk = get(g:, 'vim9skk', {})
g:vim9skk->extend(default, 'keep')
g:vim9skk.mode_label->extend(default.mode_label, 'keep')
g:vim9skk.keymap->extend(default.keymap, 'keep')
g:vim9skk.roman_table->extend(default.roman_table, 'keep')
g:vim9skk_enable = false
g:vim9skk_mode = g:vim9skk.mode_label.off

command! Vim9skkRefreshJisyo vim9skk#RefreshJisyo()
command! Vim9skkTerminalInput vim9skk#TerminalInput()
command! -nargs=1 Vim9skkRegisterToUserJisyo vim9skk#RegisterToUserJisyo(<q-args>)

noremap! <Plug>(vim9skk-toggle) <ScriptCmd>vim9skk#ToggleSkk()<CR>
noremap! <Plug>(vim9skk-enable) <ScriptCmd>vim9skk#Enable()<CR>
noremap! <Plug>(vim9skk-disable) <ScriptCmd>vim9skk#Disable()<CR>

def Map(lhs: string, keys: any, rhs: string)
  if !!keys
    for key in type(keys) ==# v:t_string ? [keys] : keys
      execute lhs key rhs
    endfor
  endif
enddef
Map('noremap!', g:vim9skk.keymap.toggle, '<Plug>(vim9skk-toggle)')
Map('tnoremap', g:vim9skk.keymap.toggle, '<ScriptCmd>Vim9skkTerminalInput<CR>')
Map('noremap!', g:vim9skk.keymap.enable, '<Plug>(vim9skk-enable)')

