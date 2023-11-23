vim9script

var default = {
  jisyo: ['~/SKK-JISYO.L:EUC-JP'],
  jisyo_user: '~/VIM9SKK-JISYO.user',
  jisyo_recent: '~/VIM9SKK-JISYO.recent',
  recent: 1000,
  parens: ['（）', '〔〕', '［］', '｛｝', '〈〉', '《》', '「」', '『』', '【】'],
  marker_midasi: '▽',
  marker_select: '▼',
  mode_label: {
    off: '_A',
    hira: 'あ',
    kata: 'ア',
    hankaku: 'ｶﾅ',
    alphabet: 'Ａ',
    abbr: 'ab',
  },
  mode_label_timeout: 3000,
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
    select: '<Space>',
    next: '<Tab>',
    prev: ['<S-Tab>', 'x'],
    complete: '<CR>',
    cancel: '<C-g>',
  },
}
g:vim9skk = default->extend(get(g:, 'vim9skk', { }))
g:vim9skk_enable = false
g:vim9skk_mode = g:vim9skk.mode_label.off

command! Vim9skkRefreshJisyo vim9skk#RefreshJisyo()
command! Vim9skkTerminalInput vim9skk#TerminalInput()
command! -nargs=1 Vim9skkRegisterToUserJisyo vim9skk#RegisterToUserJisyo(<q-args>)

noremap! <Plug>(vim9skk-toggle) <ScriptCmd>vim9skk#ToggleSkk()<CR>
noremap! <Plug>(vim9skk-enable) <ScriptCmd>vim9skk#Enable()<CR>
noremap! <Plug>(vim9skk-disable) <ScriptCmd>vim9skk#Disable()<CR>

if !!g:vim9skk.keymap.toggle
  execute $'noremap! {g:vim9skk.keymap.toggle} <Plug>(vim9skk-toggle)'
  execute $'tnoremap {g:vim9skk.keymap.toggle} <ScriptCmd>Vim9skkTerminalInput<CR>'
endif
if !!g:vim9skk.keymap.enable
  execute $'noremap! {g:vim9skk.keymap.enable} <Plug>(vim9skk-enable)'
endif
if !!g:vim9skk.keymap.disable
  execute $'noremap! {g:vim9skk.keymap.enable} <Plug>(vim9skk-disable)'
endif

