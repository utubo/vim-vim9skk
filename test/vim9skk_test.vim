vim9script

var suite = themis#suite('Test for .vimrc')
const assert = themis#helper('assert')

# テスト共通処理 {{{
const jisyo_recent = tempname()
g:vim9skk = {
  jisyo: [expand('<sfile>:p:h') .. '/SKK-JISYO.test'],
  jisyo_recent: jisyo_recent }
execute 'source' expand('<sfile>:p:h:h') .. '/plugin/vim9skk.vim'

suite.before = () => {
  writefile([''], jisyo_recent)
}

suite.after = () => {
  silent! delete(jisyo_recent)
}

suite.before_each = () => {
  vim9skk#Disable()
  normal! ggdG
}

def TestOnInsAndCmdline(keys: string, expect: string, msg: string = '')
  feedkeys($"o{keys}\<Esc>", 'xt')
  assert.equals(getline('.'), expect, $'insert-mode: {msg}')
  feedkeys($":vim9 g:a = '{keys}'\<CR>", 'xt')
  assert.equals(g:a, expect, $'cmdline: {msg}')
enddef
#}}}

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

suite.TestToggleOffOnMidashiMode = () => {
  TestOnInsAndCmdline(
    "\<C-j>A\<C-j>a",
    'あa',
    '見出しモード中にvim9skkをオフにしたら変換を確定すること'
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

suite.TestFromMidasiToAbbrev = () => {
  TestOnInsAndCmdline(
    "\<C-j>Benntou/smile\<CR>",
    'べんとうsmile',
    '見出しモード中にabbrevに切り替えて入力できること'
  )
}

suite.TestFromSelectToAbbrev = () => {
  TestOnInsAndCmdline(
    "\<C-j>Benntou\<Space>/smile\<Space>\<CR>\<C-j>",
    '弁当😄',
    '選択モード中にabbrevに切り替えて変換できること'
  )
}

suite.TestKeepSkkEnableOnInsert = () => {
  feedkeys($"o\<C-j>on\<Esc>aon\<C-j>\<Esc>aoff\<Esc>", 'xt')
  assert.equals(getline('.'), 'おんおんoff', 'インサートモードでのSKKの状態を保持すること')
}

suite.TestFromSelectToAbbrev = () => {
  vim9skk#Disable()
  feedkeys("o\<C-j>\<Esc>", 'xt')
  assert.equals(getline('.'), '', '何も入力しないキャンセルできること')
  vim9skk#Disable()
  feedkeys("o\<C-j>/\<Esc>", 'xt')
  assert.equals(getline('.'), '', '何も入力しないキャンセルできること abbrev切り替えあり ')
}
# }}}

# 変換 {{{
suite.TestHenkan = () => {
  TestOnInsAndCmdline(
    "\<C-j>Ai\<Space>\<CR>\<C-j>",
    '愛',
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

suite.TestSelectKouho = () => {
  # <Space>と<Tab>で次の候補
  # <S-Tab>とxで前の候補
  TestOnInsAndCmdline(
    "\<C-j>Suuzitesuto\<Space>\<Space>\<Tab>\<S-Tab>x\<CR>\<C-j>",
    '1',
    '候補を選択できること'
  )
}

suite.TestPrefix = () => {
  TestOnInsAndCmdline(
    "\<C-j>Zi>\<Space>Sentaku\<Space>>zi\<Space>\<CR>\<C-j>",
    '次選択時',
    '接頭辞や接尾辞を指定できること'
  )
}

suite.TestRenzoku = () => {
  TestOnInsAndCmdline(
    "\<C-j>Kanji\<Space>Henkan\<Space>\<CR>\<C-j>",
    '漢字変換',
    '選択モードから見出しモードに遷移できること'
  )
}

suite.TestKeepKatakana = () => {
  TestOnInsAndCmdline(
    "\<C-j>qKanji\<Space>\<CR>aq\<C-j>",
    '漢字ア',
    'カタカナで変換したあともカタカナをキープすること'
  )
}
# }}}

# vim9skk {{{
suite.TestMuhenkan = () => {
  TestOnInsAndCmdline(
    "\<C-j>Ai\<Space>x\<CR>qAi\<Space>x\<CR>q\<C-j>",
    'あいアイ',
    '一つ目の候補は無変換であること'
  )
}

suite.TestAutoKatakana = () => {
  TestOnInsAndCmdline(
    "\<C-j>Fantazi-\<Space>\<CR>\<C-j>",
    'ファンタジー',
    '未登録の外来語をカタカナに変換できること'
  )
}
# }}}

