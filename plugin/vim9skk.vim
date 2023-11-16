vim9script

var default = {
  jisyo: ['~/SKK-JISYO.L:EUC-JP'],
  jisyo_user: '~/VIM9SKK-USER.L',
  jisyo_recent: '~/VIM9SKK-RECENT.L',
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
  disable_default_mappings: false,
}
g:vim9skk = default->extend(get(g:, 'vim9skk', { }))
g:vim9skk_mode = g:vim9skk.mode_label.off
g:vim9skk_selectable = false

command! Vim9skkRefreshJisyo vim9skk#RefreshJisyo()
command! -nargs=1 Vim9skkRegisterToUserJisyo vim9skk#RegisterToUserJisyo(<q-args>)

noremap! <expr> <Plug>(vim9skk-toggle) vim9skk#ToggleSkk()

if g:vim9skk.disable_default_mappings
  finish
endif
noremap! <C-j> <Plug>(vim9skk-toggle)
lnoremap <C-j> <Plug>(vim9skk-toggle)
lnoremap q     <Plug>(vim9skk-kana)
lnoremap <C-q> <Plug>(vim9skk-hankaku)
lnoremap L     <Plug>(vim9skk-alphabet)
lnoremap /     <Plug>(vim9skk-abbr)
lnoremap Q     <Plug>(vim9skk-midasi)
lnoremap <expr> <Tab> g:vim9skk_selectable ? '<Plug>(vim9skk-next)' : '<TAB>'
lnoremap <S-Tab> <Plug>(vim9skk-prev)

