vim9script

var default = {
  jisyo: ['~/SKK-JISYO.L:EUC-JP'],
  jisyo_user: '~/VIM9SKK-JISYO.user',
  jisyo_recent: '~/VIM9SKK-JISYO.recent',
  recent: 1000,
  space: ' ',
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
  disable_default_mappings: false,
}
g:vim9skk = default->extend(get(g:, 'vim9skk', { }))
g:vim9skk_enable = false
g:vim9skk_mode = g:vim9skk.mode_label.off
g:vim9skk_selectable = false

command! Vim9skkRefreshJisyo vim9skk#RefreshJisyo()
command! Vim9skkTerminalInput vim9skk#TerminalInput()
command! -nargs=1 Vim9skkRegisterToUserJisyo vim9skk#RegisterToUserJisyo(<q-args>)
command! -nargs=* Vim9skkMap vim9skk#Vim9skkMap(<q-args>)

noremap! <Plug>(vim9skk-toggle) <ScriptCmd>vim9skk#ToggleSkk()<CR>
noremap! <Plug>(vim9skk-enable) <ScriptCmd>vim9skk#Enable()<CR>
noremap! <Plug>(vim9skk-disable) <ScriptCmd>vim9skk#Disable()<CR>

if g:vim9skk.disable_default_mappings
  finish
endif
noremap! <C-j> <Plug>(vim9skk-toggle)
tnoremap <C-j> <ScriptCmd>Vim9skkTerminalInput<CR>
Vim9skkMap q     <Plug>(vim9skk-kana)
Vim9skkMap <C-q> <Plug>(vim9skk-hankaku)
Vim9skkMap L     <Plug>(vim9skk-alphabet)
Vim9skkMap /     <Plug>(vim9skk-abbr)
Vim9skkMap Q     <Plug>(vim9skk-midasi)
Vim9skkMap <C-g> <Plug>(vim9skk-cancel)
Vim9skkMap <expr> <Tab> g:vim9skk_selectable ? '<Plug>(vim9skk-next)' : '<TAB>'
Vim9skkMap <S-Tab> <Plug>(vim9skk-prev)

