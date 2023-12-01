vim9script

var suite = themis#suite('Test for .vimrc')
const assert = themis#helper('assert')

g:vim9skk = {
  jisyo: [expand('<sfile>:p:h') .. '/SKK-JISYO.test']
}

execute 'source' expand('<sfile>:p:h:h') .. '/plugin/vim9skk.vim'

suite.before_each = () => {
  normal! ggdG
}

def TestOnInsAndCmdline(keys: string, expect: string, msg: string = '')
  feedkeys($"o{keys}\<Esc>", 'xt')
  assert.equals(getline('.'), expect, $'insert-mode: {msg}')
  feedkeys($":vim9 g:a = '{keys}'\<CR>", 'xt')
  assert.equals(g:a, expect, $'cmdline: {msg}')
enddef

# モード切り替え等 {{{
suite.TestHiragana = () => {
  TestOnInsAndCmdline(
    "\<C-j>aiueokattan\<C-j>",
    'あいうえおかったん',
    'ひらがなを入力できること'
  )
}

suite.TestKatakana = () => {
  TestOnInsAndCmdline(
    "\<C-j>qaiueokattanqa\<C-j>",
    'アイウエオカッタンあ',
    '全角カナを入力できること'
  )
}

suite.TestHankaku = () => {
  TestOnInsAndCmdline(
    "\<C-j>\<C-q>aiueokattan\<C-q>a\<C-j>",
    'ｱｲｳｴｵｶｯﾀﾝあ',
    '半角ｶﾅを入力できること'
  )
}

suite.TestZenei = () => {
  TestOnInsAndCmdline(
    "\<C-j>Laiueokattan\<C-j>a\<C-j>",
    'ａｉｕｅｏｋａｔｔａｎあ',
    '全角英数を入力できること'
  )
}

suite.TestAbbr = () => {
  TestOnInsAndCmdline(
    "\<C-j>a/smile\<CR>\<C-j>",
    'あsmile',
    'abbrモードで半角英数を入力できること'
  )
}

suite.TestToggleOff = () => {
  TestOnInsAndCmdline(
    "\<C-j>a\<C-j>a",
    'あa',
    'vim9skkをオフにできること'
  )
}

suite.TestToKatakana = () => {
  TestOnInsAndCmdline(
    "\<C-j>Katakanaq\<C-j>",
    'カタカナ',
    '入力後にカタカナへ変換できること'
  )
}

suite.TestToHankaku = () => {
  TestOnInsAndCmdline(
    "\<C-j>Hankaku\<C-q>\<C-j>",
    'ﾊﾝｶｸ',
    '入力後に半角ｶﾅへ変換できること'
  )
}

suite.TestToHankakuFromKatakana = () => {
  TestOnInsAndCmdline(
    "\<C-j>qHankaku\<C-q>\<C-j>",
    'ﾊﾝｶｸ',
    '全角カナで入力後に半角ｶﾅへ変換できること'
  )
}

# }}}

# 変換 {{{
suite.TestHenkan = () => {
  TestOnInsAndCmdline(
    "\<C-j>Ai\<Space>\<CR>Ai\<Space>\<Space>\<CR>Ai\<Space>\<Space>\<CR>\<C-j>",
    '愛合愛',
    '漢字変換できること'
  )
}

suite.TestHenkanAbbr = () => {
  TestOnInsAndCmdline(
    "\<C-j>/smile\<Space>\<CR>\<C-j>",
    '😄',
    'abbrで半角英数を変換できること'
  )
}

suite.TestOkuri = () => {
  const c = "\<Space>\<CR>"
  TestOnInsAndCmdline(
    $"\<C-j>KonbiniqdeKaTTa{c}Bentou{c}woTaBeru{c}\<C-j>",
    'コンビニで買った弁当を食べる',
    '送り仮名に対応していること'
  )
}
# }}}

