vim9script

# スクリプトローカル変数 {{{
const mode_hira = 1
const mode_kata = 2
const mode_hankaku = 3
const mode_alphabet = 4
const mode_abbr = 5

const skkmode_direct = 0
const skkmode_midasi = 1
const skkmode_select = 2

var initialized = false
var mode = { id: mode_hira, use_roman: true, items: [] }
var skkmode = skkmode_direct
var start_pos = 0
var end_pos = 1
var pos_delta = 0 # 確定前後のカーソル位置の差異
var henkan_key = ''
var okuri = ''
var kouho = []
var kouho_index = -1
var last_word = ''
var jisyo = {}
var recent_jisyo = {}
var chain_jisyo = {}
var pum_winid = 0
var is_registering_user_jisyo = false

var roman_table = {
  # 4文字
  ltsu: 'っ', xtsu: 'っ',
  # 3文字
  gya: 'ぎゃ', gyi: 'ぎぃ', gyu: 'ぎゅ', gye: 'ぎぇ', gyo: 'ぎょ',
  zya: 'じゃ', zyi: 'じぃ', zyu: 'じゅ', zye: 'じぇ', zyo: 'じょ',
  dya: 'ぢゃ', dyi: 'でぃ', dyu: 'ぢゅ', dye: 'ぢぇ', dyo: 'ぢょ',
  dha: 'ぢゃ', dhi: 'でぃ', dhu: 'ぢゅ', dhe: 'ぢぇ', dho: 'ぢょ',
  bya: 'びゃ', byi: 'びぃ', byu: 'びゅ', bye: 'びぇ', byo: 'びょ',
  pya: 'ぴゃ', pyi: 'ぴぃ', pyu: 'ぴゅ', pye: 'ぴぇ', pyo: 'ぴょ',
  kya: 'きゃ', kyi: 'きぃ', kyu: 'きゅ', kye: 'きぇ', kyo: 'きょ',
  sya: 'しゃ', syi: 'しぃ', syu: 'しゅ', sye: 'しぇ', syo: 'しょ',
  sha: 'しゃ', shi: 'し',   shu: 'しゅ', she: 'しぇ', sho: 'しょ',
  tya: 'ちゃ', tyi: 'ち',   tyu: 'ちゅ', tye: 'ちぇ', tyo: 'ちょ',
  cha: 'ちゃ', chi: 'ちぃ', chu: 'ちゅ', che: 'ちぇ', cho: 'ちょ',
  tsa: 'つぁ', tsi: 'つぃ', tsu: 'つ',   tse: 'つぇ', tso: 'つぉ',
  tha: 'てゃ', thi: 'てぃ', thu: 'てゅ', the: 'てぇ', tho: 'てょ',
  nya: 'にゃ', nyi: 'にぃ', nyu: 'にゅ', nye: 'にぇ', nyo: 'にょ',
  hya: 'ひゃ', hyi: 'ひぃ', hyu: 'ひゅ', hye: 'ひぇ', hyo: 'ひょ',
  mya: 'みゃ', myi: 'みぃ', myu: 'みゅ', mye: 'みぇ', myo: 'みょ',
  rya: 'りゃ', ryi: 'りぃ', ryu: 'りゅ', rye: 'りぇ', ryo: 'りょ',
  lya: 'ゃ', lyu: 'ゅ', lyo: 'ょ', ltu: 'っ', lwa: 'ゎ',
  xya: 'ゃ', xyu: 'ゅ', xyo: 'ょ', xtu: 'っ', xwa: 'ゎ',
  # 2文字
  cc: 'っc',
  ja: 'じゃ', ji: 'じ', ju: 'じゅ', je: 'じぇ', jo: 'じょ', jj: 'っj',
  fa: 'ふぁ', fi: 'ふぃ', fu: 'ふ', fe: 'ふぇ', fo: 'ふぉ', ff: 'っf',
  va: 'ゔぁ', vi: 'ゔぃ', vu: 'ゔ', ve: 'ゔぇ', vo: 'ゔぉ',
  la: 'ぁ', li: 'ぃ', lu: 'ぅ', le: 'ぇ', lo: 'ぉ',
  xa: 'ぁ', xi: 'ぃ', xu: 'ぅ', xe: 'ぇ', xo: 'ぉ',
  ga: 'が', gi: 'ぎ', gu: 'ぐ', ge: 'げ', go: 'ご', gg: 'っg',
  za: 'ざ', zi: 'じ', zu: 'ず', ze: 'ぜ', zo: 'ぞ', zz: 'っz',
  da: 'だ', di: 'ぢ', du: 'づ', de: 'で', do: 'ど', dd: 'っd',
  ba: 'ば', bi: 'び', bu: 'ぶ', be: 'べ', bo: 'ぼ', bb: 'っb',
  pa: 'ぱ', pi: 'ぴ', pu: 'ぷ', pe: 'ぺ', po: 'ぽ', pp: 'っp',
  ka: 'か', ki: 'き', ku: 'く', ke: 'け', ko: 'こ', kk: 'っk',
  sa: 'さ', si: 'し', su: 'す', se: 'せ', so: 'そ', ss: 'っs',
  ta: 'た', ti: 'ち', tu: 'つ', te: 'て', to: 'と', tt: 'っt',
  na: 'な', ni: 'に', nu: 'ぬ', ne: 'ね', no: 'の',
  ha: 'は', hi: 'ひ', hu: 'ふ', he: 'へ', ho: 'ほ', hh: 'っh',
  ma: 'ま', mi: 'み', mu: 'む', me: 'め', mo: 'も', mm: 'っm',
  ya: 'や', yi: 'ゐ', yu: 'ゆ', ye: 'ゑ', yo: 'よ', yy: 'っy',
  ra: 'ら', ri: 'り', ru: 'る', re: 'れ', ro: 'ろ', rr: 'っr',
  wa: 'わ', wo: 'を', nn: 'ん',
  # 1文字
  a: 'あ', i: 'い', u: 'う', e: 'え', o: 'お', n: 'ん',
  # 記号
  'z ': '　', 'z.': '…', 'z/': '・', 'z[': '「', 'z]': '」',
  zl: '→', zh: '←', zj: '↓', zk: '↑',
  '-': 'ー', '.': '。', ',': '、', '!': '！', '?': '？', '/': '・', '~': '～',
}
# Init()で作る
#const roman_table_items = roman_table->items()
var roman_table_items = []

# {か:'k'}みたいなdict
# 変換時に「けんさく*する」→「けんさくs」という風に辞書を検索する時に使う
# Init()で作る
var okuri_table = {}

const hira_chars = ('ぁあぃいぅうぇえぉおかがきぎくぐけげこご' ..
  'さざしじすずせぜそぞただちぢっつづてでとど' ..
  'なにぬねのはばぱひびぴふぶぷへべぺほぼぽ' ..
  'まみむめもゃやゅゆょよらりるれろゎわゐゑをんゔー　')->split('.\zs')

const kata_chars = ('ァアィイゥウェエォオカガキギクグケゲコゴ' ..
  'サザシジスズセゼソゾタダチヂッツヅテデトド' ..
  'ナニヌネノハバパヒビピフブプヘベペホボポ' ..
  'マミムメモャヤュユョヨラリルレロヮワヰヱヲンヴー　')->split('.\zs')

const hankaku_chars = ('ｧｱｨｲｩｳｪｴｫｵｶｶﾞｷｷﾞｸｸﾞｹｹﾞｺｺﾞ' ..
  'ｻｻﾞｼｼﾞｽｽﾞｾｾﾞｿｿﾞﾀﾀﾞﾁﾁﾞｯﾂﾂﾞﾃﾃﾞﾄﾄﾞ' ..
  'ﾅﾆﾇﾈﾉﾊﾊﾞﾊﾟﾋﾋﾞﾋﾟﾌﾌﾞﾌﾟﾍﾍﾞﾍﾟﾎﾎﾞﾎﾟ' ..
  'ﾏﾐﾑﾒﾓｬﾔｭﾕｮﾖﾗﾘﾙﾚﾛﾜﾜｲｴｦﾝｳﾞｰ ')->split('.[ﾟﾞ]\?\zs')

const alphabet_chars = ('０１２３４５６７８９' ..
  'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ' ..
  'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ' ..
  '　！＂＃＄％＆＇（）－＾＼＠［；：］，．／＼＝～｜｀｛＋＊｝＜＞？＿')->split('.\zs')

const abbr_chars = ('0123456789' ..
  'abcdefghijklmnopqrstuvwxyz' ..
  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ..
  '!"#$%&''()-^\@[;:],./\=~|`{+*}<>?_')->split('.\zs')
# }}}

# ユーティリティー {{{
# tr()を使いたいけど、半角カナ濁点半濁点に対応しないといけないので自作
# 半角カナ→ひらがなorカタカナはNG
def ConvChars(str: string, from_chars: list<string>, to_chars: list<string>): string
  var dest = []
  for c in str->split('.\zs')
    const i = from_chars->index(c)
    dest += [i ==# - 1 ? c : to_chars[i]]
  endfor
  return dest->join('')
enddef

def SwapChars(str: string, a: list<string>, b: list<string>): string
  return str->ConvChars(a + b, b + a)
enddef

def GetLine(): string
  return mode() ==# 'c' ? getcmdline() : getline('.')
enddef

def GetPos(): number
  return mode() ==# 'c' ? getcmdpos() : col('.')
enddef

def AddStr(a: string, b: string): string
  return a .. b
enddef

def StartsWith(str: string, expr: string): bool
  return str->strcharpart(0, expr->strchars()) ==# expr
enddef

# 文字列を必ず2つに分割する
def Split(str: string, dlm: string): list<string>
  const i = str->stridx(dlm)
  return i ==# - 1 ? [str, ''] : [str->strpart(0, i), str->strpart(i + 1)]
enddef

# 順番を保ったままuniqする
def Uniq(list: list<any>): list<any>
  var result = []
  for a in list
    if result->Excludes(a)
      result->add(a)
    endif
  endfor
  return result
enddef

def ToItems(list: list<any>, CreateKeyValueFunc: func): list<list<any>>
  var d = {}
  for i in list
    const [k, v] = CreateKeyValueFunc(i)
    d[k] = v
  endfor
  return d->items()
enddef

def Includes(a: list<any>, b: any): bool
  return a->index(b) !=# -1
enddef

def Excludes(a: list<any>, b: any): bool
  return a->index(b) ==# -1
enddef

def ForEach(a: list<any>, F: func)
  for v in a
    if !!v
      F(v)
    endif
  endfor
enddef

def DoUserEvent(event: string)
  if exists($'#User#{event}')
    execute $'doautocmd User {event}'
  endif
enddef
# }}}

# 基本 {{{
def Init()
  DoUserEvent('Vim9skkInitPre')
  augroup vim9skk
    autocmd!
    autocmd BufEnter * MapToBuf()
    autocmd InsertEnter * OnInsertEnter()
    autocmd InsertLeavePre * OnInsertLeavePre()
    autocmd CmdlineEnter * OnCmdlineEnter()
    autocmd CmdlineLeave * OnCmdlineLeavePre()
    autocmd VimLeave * SaveRecentJisyo()
  augroup END
  # ユーザー定義のローマ字入力を追加
  roman_table->extend(g:vim9skk.roman_table)
  roman_table_items = roman_table->items()
  # 送り仮名テーブルを作成
  for [k, v] in roman_table_items
    okuri_table[v->strcharpart(0, 1)] = k[0]
  endfor
  # 辞書のパスのワイルドカードを展開しておく
  var expanded = []
  for j in g:vim9skk.jisyo
    const [path, enc] = ToFullPathAndEncode(j)
    for p in path->split('\n')
      expanded += [$'{p}:{enc}']
    endfor
  endfor
  g:vim9skk.jisyo = expanded
  # その他初期化処理
  SetMode(mode_hira)
  initialized = true
enddef

export def Enable()
  if g:vim9skk_enable
    return
  endif
  g:vim9skk_enable = true
  if !initialized
    Init()
  endif
  MapToBuf()
  ToDirectMode()
  ShowMode(true)
  DoUserEvent('Vim9skkModeChanged')
  DoUserEvent('Vim9skkEnter')
enddef

export def Disable(popup_even_off: bool = true)
  if !g:vim9skk_enable
    return
  endif
  if skkmode !=# skkmode_direct
    Complete()->feedkeys('nit')
  endif
  g:vim9skk_enable = false
  UnmapAll()
  CloseKouho()
  ShowMode(popup_even_off)
  DoUserEvent('Vim9skkModeChanged')
  DoUserEvent('Vim9skkLeave')
enddef

export def ToggleSkk()
  if g:vim9skk_enable && !mode.use_roman
    SetMode(mode_hira)
  elseif g:vim9skk_enable
    Disable()
  else
    Enable()
  endif
enddef

def OnInsertEnter()
  ShowMode(false)
enddef

def OnInsertLeavePre()
  if !g:vim9skk_enable
    return
  endif
  CloseKouho()
  if skkmode ==# skkmode_direct
    return
  endif
  const before = GetTarget()
  const after = before->RemoveMarker()
  setline('.', getline('.')->substitute(
    $'\%{start_pos}c{"."->repeat(strchars(before))}',
    after,
    ''
  ))
  ToDirectMode()
  TurnOffAbbr()
  RegisterToChainJisyo(after)
  RegisterToChainJisyo('')
enddef

def OnCmdlineEnter()
  # '@'も含めたいがredrawでecho出力がクリアされてしまう
  if getcmdtype() =~# '[/?]'
    ShowMode(false)
  elseif getcmdtype() ==# ':'
    Disable(false)
  else
    ClosePum()
  endif
  if g:vim9skk_enable
    ToDirectMode()
  endif
enddef

def OnCmdlineLeavePre()
  if g:vim9skk_enable
    CloseKouho()
    TurnOffAbbr()
  endif
enddef
# }}}

# ちらつき防止 {{{
var lock_redraw = false

def Redraw()
  if !lock_redraw
    redraw
  endif
enddef

def ExecuteWithoutRedraw(F: func)
  lock_redraw = true
  F()
  lock_redraw = false
enddef
# }}}

# 入力モード制御 {{{
var mode_settings_cache = {}
def GetModeSettings(m: number): any
  if !mode_settings_cache->has_key(m)
    mode_settings_cache[m] = CreateModeSettings(m)
  endif
  return mode_settings_cache[m]
enddef

def CreateModeSettings(m: number): any
  if m ==# mode_hira
    return {
      id: mode_hira,
      label: g:vim9skk.mode_label.hira,
      use_roman: true,
      items: roman_table_items
    }
  elseif m ==# mode_kata
    return {
      id: mode_kata,
      label: g:vim9skk.mode_label.kata,
      use_roman: true,
      items: roman_table_items
        ->ToItems((i) => [i[0], i[1]->ConvChars(hira_chars, kata_chars)])
    }
  elseif m ==# mode_hankaku
    return {
      id: mode_hankaku,
      label: g:vim9skk.mode_label.hankaku,
      use_roman: true,
      items: roman_table_items
        ->ToItems((i) => [i[0], i[1]->ConvChars(hira_chars, hankaku_chars)])
    }
  elseif m ==# mode_alphabet
    return {
      id: mode_alphabet,
      label: g:vim9skk.mode_label.alphabet,
      use_roman: false,
      items: abbr_chars
        ->ToItems((i) => [i, i->ConvChars(abbr_chars, alphabet_chars)])
    }
  else
    return {
      id: mode_abbr,
      label: g:vim9skk.mode_label.abbr,
      use_roman: false,
      items: abbr_chars->ToItems((i) => [i, i])
    }
  endif
enddef

def SetMode(m: number)
  mode = GetModeSettings(m)
  MapDirectMode()
  if skkmode !=# skkmode_select
    ShowMode(true)
  endif
  silent! doautocmd User Vim9skkModeChanged
enddef

def ToDirectMode(chain: string = '', delta: number = 0): string
  SetSkkMode(skkmode_direct)
  start_pos = GetPos() - delta
  return chain
enddef

def SetSkkMode(s: number)
  if skkmode !=# s
    skkmode = s
    MapMidasiMode()
    if s ==# skkmode_midasi && !g:vim9skk.marker_midasi
      ShowMode(false)
    endif
  endif
enddef

def ToggleMode(m: number): string
  if skkmode ==# skkmode_direct
    SetMode(mode.id !=# m ? m : mode_hira)
    return ''
  else
    const k_chars = m ==# mode_kata ? kata_chars : hankaku_chars
    const mm = GetModeSettings(m)
    const before = GetTarget()->RemoveMarker()
    const after = before
      ->SwapChars(hira_chars, k_chars)
      ->ConvChars(kata_chars, k_chars)
      ->SwapChars(alphabet_chars, abbr_chars)
    RegisterToRecentJisyo(before, after)
    return after->ReplaceTarget()->ToDirectMode()
  endif
enddef

def ToggleAbbr(): string
  if mode.id ==# mode_abbr
    TurnOffAbbr()
    if skkmode ==# skkmode_midasi || skkmode ==# skkmode_select
      return Complete()
    endif
    TurnOffAbbr()
    return ''
  elseif skkmode ==# skkmode_midasi
    SetMode(mode_abbr)
    return ''
  elseif skkmode ==# skkmode_select
    const c = Complete()
    SetMode(mode_abbr)
    return c .. SetMidasi('', len(g:vim9skk.marker_midasi))
  else
    SetMode(mode_abbr)
    return SetMidasi()
  endif
enddef

def TurnOffAbbr(): string
  if mode.id ==# mode_abbr
    UnmapAll()
    SetMode(mode_hira)
  endif
  return ''
enddef

def ShowMode(popup_even_off: bool)
  g:vim9skk_mode = g:vim9skk_enable
    ? skkmode ==# skkmode_midasi
    ? g:vim9skk.mode_label.midasi
    : mode.label
    : g:vim9skk.mode_label.off
  if !!g:vim9skk_mode && 0 < g:vim9skk.mode_label_timeout && (popup_even_off || g:vim9skk_enable)
    # マーカーを削除することで位置がズレるのでtimerで誤魔化す
    timer_start(1, (t: number) => {
      ClosePum()
      pum_winid = popup_create(g:vim9skk_mode, {
        col: mode() ==# 'c' ? getcmdscreenpos() : 'cursor',
        line: mode() ==# 'c' ? (&lines - 1) : 'cursor+1',
        time: g:vim9skk.mode_label_timeout, })
      Redraw()
    })
  else
    ClosePum()
    Redraw()
  endif
enddef

def ClosePum()
  if !!pum_winid
    popup_close(pum_winid)
    pum_winid = 0
    kouho_index = -1
    Redraw()
  endif
enddef
# }}}

# キー入力 {{{
def EscapeForMap(key: string): string
  return key
    ->substitute('<', '<LT>', 'g')
    ->substitute('|', '<Bar>', 'g')
    ->substitute(' ', '<Space>', 'g')
    ->substitute('\', '<Bslash>', 'g')
enddef

def MapFunction(keys: any, f: string, enable: bool = true)
  for key in type(keys) ==# v:t_string ? [keys] : keys
    if enable
      # 選択モードのxや全英モードのLに対応するための面倒なif文
      if skkmode ==# skkmode_select || mode.use_roman || abbr_chars->Excludes(key)
        const nowait = len(key) ==# 1 ? '<nowait>' : ''
        execute $'map! <buffer> <script> {nowait} {key} <ScriptCmd>{f}->feedkeys("nit")<CR>'
      endif
    else
      silent! execute $'unmap! <buffer> <script> {key}'
      get(b:, 'vim9skk_saved_roman', {})->get(key, [])->ForEach((m) => mapset(m))
    endif
  endfor
enddef

# <buffer>にマッピングしないと他のプラグインに取られちゃう
def MapToBuf()
  if !g:vim9skk_enable
    return
  endif
  UnmapAll()
  b:vim9skk_saved_keymap = maplist()->filter((_, m) => m.buffer)
  MapDirectMode()
  MapMidasiMode()
  MapSelectMode(!!kouho)
enddef

def MapDirectMode()
  if get(b:, 'vim9skk_keymapped', 0) ==# mode.id
    return
  endif
  b:vim9skk_keymapped = mode.id
  MapRoman()
  # 見出しモードや選択モードから戻ってきたときのためのバックアップ
  b:vim9skk_saved_roman = {}
  for key in g:vim9skk.keymap->values()->flattennew()
    b:vim9skk_saved_roman[key] = [
      maparg(key, 'i', false, true),
      maparg(key, 'c', false, true),
    ]
  endfor
  MapFunction(g:vim9skk.keymap.kata,     'ToggleMode(mode_kata)')
  MapFunction(g:vim9skk.keymap.hankaku,  'ToggleMode(mode_hankaku)')
  MapFunction(g:vim9skk.keymap.alphabet, 'ToggleMode(mode_alphabet)')
  MapFunction(g:vim9skk.keymap.abbr,     'ToggleAbbr()')
  MapFunction(g:vim9skk.keymap.midasi,   'U("")') # 大文字を押したのと同じ
  # leximaなどがinsertモードを解除してしまうので…
  noremap! <buffer> <script> <BS> <BS>
enddef

def MapRoman()
  if mode.use_roman
    for k in 'ABCDEFGHIJKMNOPRSTUVWXYZ'->split('.\zs')
      silent! execute $'unmap! <buffer> <script> {k->tolower()}'
      execute $'map! <buffer> <script> <nowait> {k} <ScriptCmd>U("{k}")->feedkeys("it")<CR>'
    endfor
  else
    # <nowait>でいけるかな？と思ったけど、ちゃんとunmapしないとテストが通らない
    for [key, value] in roman_table_items
      const k = key->EscapeForMap()
      silent! execute $'unmap! <buffer> <script> {k}'
    endfor
  endif
  const map = mode.use_roman ? 'map!' : 'noremap! <nowait>'
  for [key, value] in mode.items
    const k = key->EscapeForMap()
    const v = value->escape('"|\\')
    const flg = mode.use_roman && value =~# '[a-z]$' ? 'it' : 'nit'
    execute $'{map} <buffer> <script> {k} <ScriptCmd>L("{v}")->feedkeys("{flg}")<CR>'
  endfor
enddef

def MapMidasiMode()
  if g:vim9skk_enable
    const enable = skkmode !=# skkmode_direct
    MapFunction(g:vim9skk.keymap.select,   'StartSelect()', enable)
    MapFunction(g:vim9skk.keymap.complete, 'Complete()', enable)
    MapFunction(g:vim9skk.keymap.cancel,   'Select(-kouho_index)->Complete()', enable)
    MapFunction(g:vim9skk.keymap.prefix,   'SetPrefix()', enable)
  endif
enddef

def MapSelectMode(enable: bool)
  if g:vim9skk_enable
    MapFunction(g:vim9skk.keymap.next, 'Select(1)', enable)
    MapFunction(g:vim9skk.keymap.prev, 'Select(-1)', enable)
  endif
enddef

def UnmapAll()
  if !get(b:, 'vim9skk_keymapped', 0)
    return
  endif
  b:vim9skk_keymapped = 0
  for m in maplist()->filter((_, m) => m.script) # cmdlineはm.buffer無し
    const lhs = m.lhs
      ->substitute('|', '<BAR>', 'g')
      ->substitute('\', '<Bslash>', 'g')
    silent! execute $'unmap! <buffer> <script> {lhs}'
  endfor
  for m in get(b:, 'vim9skk_saved_keymap', [])
    mapset(m)
  endfor
  b:vim9skk_saved_keymap = []
enddef

# 小文字入力時(Lower)
def L(chain: string): string
  var prefix = ''
  if skkmode ==# skkmode_select
    prefix = Complete()
  elseif skkmode ==# skkmode_midasi
    GetTarget()
      ->Split(g:vim9skk.marker_okuri)[0]
      ->RemoveMarker()
      ->AddStr(chain)
      ->ShowRecent()
  endif
  if !kouho
    ShowMode(true)
  endif
  return prefix .. chain
enddef

# 大文字入力時(Upper)
def U(key: string): string
  # 選択モードなら確定して見出しをセットする
  if skkmode ==# skkmode_select
    return Complete() .. key
  endif
  const target = GetTarget()
  # 見出しマークがなければ見出しモードへ遷移する
  if skkmode ==# skkmode_direct || !target->StartsWith(g:vim9skk.marker_midasi)
    return SetMidasi(key)
  endif
  # 見出しモードなら…
  var prefix = ''
  const sion = target->matchstr('[a-z]*$')
  if !!sion && !!key
    # Shift押しっぱなしでもローマ字入力できるように頑張る
    prefix = repeat("\<BS>", sion->len()) .. sion
  elseif target !~# g:vim9skk.marker_okuri && target !=# g:vim9skk.marker_midasi
    # 送り仮名マーカーを設置する
    prefix = g:vim9skk.marker_okuri
  endif
  return prefix .. key->tolower()
enddef

def SetMidasi(key: string = '', delta: number = 0): string
  SetSkkMode(skkmode_midasi)
  const next_start_pos = GetPos() - delta
  const next_word = GetLine()->matchstr($'\%{end_pos}c.*\%{next_start_pos}c')
  if !!next_word
    RegisterToChainJisyo(next_word)
  endif
  start_pos = next_start_pos
  return g:vim9skk.marker_midasi .. key->tolower()
enddef

def SetPrefix(): string
  if skkmode ==# skkmode_select
    return Complete() .. SetMidasi(g:vim9skk.keymap.prefix, pos_delta)
  else
    return g:vim9skk.keymap.prefix
  endif
enddef
# }}}

# 変換 {{{
def GetTarget(): string
  return GetLine()->matchstr($'\%{start_pos}c.*\%{GetPos()}c')
enddef

def RemoveMarker(s: string): string
  return s
    ->substitute(g:vim9skk.marker_midasi, '', '')
    ->substitute(g:vim9skk.marker_select, '', '')
    ->substitute(g:vim9skk.marker_okuri, '', '')
enddef

def ReplaceTarget(after: string): string
  return "\<BS>"->repeat(strchars(GetTarget())) .. after
enddef

def StartSelect(): string
  if skkmode ==# skkmode_select
    return Select(1)
  endif
  const target = GetTarget()
  target->GetAllKouho()
  if !kouho
    CloseKouho()
    return ''
  endif
  SetSkkMode(skkmode_select)
  PopupKouho(target)
  kouho_index = 0
  return Select(1)
enddef

def GetKouhoFromJisyo(path: string, key: string): list<string>
  const j = ReadJisyo(path)
  const head = $'{key} '->IconvTo(j.enc)
  const max = len(j.lines) - 1
  if max < 0
    return []
  endif
  var limit = g:vim9skk.search_limit
  var d = max
  var i = max / 2
  while !!limit
    limit -= 1
    const line = j.lines[i]
    if line->StartsWith(head)
      return line->IconvFrom(j.enc)->Split(' ')[1]->split('/')
    endif
    d = d / 2 + d % 2
    if d <= 1
      if !!limit
        # 残りの探索が奇数個だと取り漏らすので、あと1回だけ探索がんばる
        limit = 1
        d = 1
      else
        # もうだめ
        break
      endif
    endif
    i += line < head ? d : -d
    i = i < 0 ? 0 : max < i ? max : i
  endwhile
  return []
enddef

def GetAllKouho(target: string)
  if !target
    kouho = []
    return
  endif
  # `▽ほげ*ふが`を見出しと送り仮名に分割する
  const [m, o] = target
    ->substitute(g:vim9skk.marker_midasi, '', '')
    ->Split(g:vim9skk.marker_okuri)
  kouho = [m] # 候補一つ目は無変換
  okuri = o # 送り仮名は候補選択時に使うのでスクリプトローカルに保持しておく
  # 候補を検索する
  const midasi_key = m->ConvChars(kata_chars, hira_chars)
  const okuri_key = o
    ->ConvChars(kata_chars, hira_chars)
    ->substitute('^っ*', '', '')
    ->matchstr('^.')
  henkan_key = $'{midasi_key}{okuri_table->get(okuri_key, '')}' # `ほげf`
  for path in [g:vim9skk.jisyo_recent, g:vim9skk.jisyo_user] + g:vim9skk.jisyo
    kouho += GetKouhoFromJisyo(path, henkan_key)
  endfor
  kouho = kouho->Uniq()
  if len(kouho) ==# 1
    if m =~# '[ゔーぱぴぷぺぽ]'
      kouho += [m->ConvChars(hira_chars, kata_chars)]
    else
      kouho = RegisterToUserJisyo(henkan_key)
    endif
  endif
enddef

def Cyclic(a: number, max: number): number
  return max ==# 0 ? 0 : ((a % max + max) % max)
enddef

def GetSelectedKouho(): string
  return kouho->get(kouho_index, '')->substitute(';.*', '', '')
enddef

def Select(d: number): string
  SetSkkMode(skkmode_select)
  kouho_index = Cyclic(kouho_index + d, len(kouho))
  HighlightKouho()
  return ReplaceTarget($'{g:vim9skk.marker_select}{GetSelectedKouho()}{okuri}')
enddef

def AddLeftForParen(chain: string, p: string): string
  if g:vim9skk.parens->Includes(p)
    return chain .. "\<C-g>U\<Left>"
  else
    return chain
  endif
enddef

def Complete(chain: string = ''): string
  const before = GetTarget()
  const after = before->RemoveMarker()
  pos_delta = before->len() - after->len()
  RegisterToRecentJisyo(henkan_key, GetSelectedKouho())
  RegisterToChainJisyo(after)
  TurnOffAbbr()
  kouho = []
  henkan_key = ''
  return chain ..
    after
      ->ReplaceTarget()
      ->AddLeftForParen(after)
      ->ToDirectMode(pos_delta)
      ->AfterComplete()
enddef

def AfterComplete(chain: string): string
  ShowChainJisyo()
  if !kouho
    ShowMode(true)
  endif
  return chain
enddef
# }}}

# 変換履歴をポップアップ {{{
def AddDetail(list: list<string>, detail: string): list<string>
  var result = []
  for i in list
    result += [$'{i};{detail}']
  endfor
  return result
enddef

def ShowRecent(target: string)
  kouho = []
  const j = ReadRecentJisyo()
  const head = target->IconvTo(j.enc)
  for line in j.lines
    if line->StartsWith(head)
      kouho += line->IconvFrom(j.enc)->Split(' ')[1]->split('/')
    endif
  endfor
  if !len(kouho)
    CloseKouho()
  else
    kouho = kouho->Uniq()->AddDetail('変換履歴')
    kouho_index = -1
    okuri = ''
    PopupKouho(target)
  endif
enddef
# }}}

# 候補をポップアップ {{{
def PopupKouho(target: string)
  if !target && mode() ==# 'c'
    # getscreencmdposがずれるのでSafeStateを待ってから表示する
    au vim9skk SafeState * ++once PopupKouhoImpl('')
  else
    PopupKouhoImpl(target)
  endif
enddef

def PopupKouhoImpl(target: string)
  CloseKouho->ExecuteWithoutRedraw()
  if !kouho
    Redraw()
    return
  endif
  MapSelectMode(true)
  if g:vim9skk.popup_maxheight <= 0
    return
  endif
  const midasi_width = !target ? 0 : strdisplaywidth(g:vim9skk.marker_midasi)
  var pum_options = {
    col: screenpos(0, line('.'), start_pos).col + midasi_width,
    line: 'cursor+1',
    pos: 'topleft',
    cursorline: true,
    maxheight: g:vim9skk.popup_maxheight,
  }
  if mode() ==# 'c'
    pum_options.col = getcmdscreenpos() - strdisplaywidth(target) + midasi_width
    pum_options.line = &lines - 1
    pum_options.pos = 'botleft'
  elseif &lines - g:vim9skk.popup_minheight < screenrow()
    pum_options.line = 'cursor-1'
    pum_options.pos = 'botleft'
  endif
  var width = 0
  for k in kouho
    const w = strdisplaywidth(k)
    if width < w
      width = w
    endif
  endfor
  pum_options.col = max([0, min([&columns - width, pum_options.col])])
  pum_winid = popup_create(kouho, pum_options)
  win_execute(pum_winid, ':%s/;/\t/g', 'silent!')
  win_execute(pum_winid, 'setlocal tabstop=12')
  win_execute(pum_winid, 'syntax match PMenuExtra /\t.*/')
  HighlightKouho()
enddef

def HighlightKouho()
  if pum_winid !=# 0
    win_execute(pum_winid, $':{kouho_index + 1}')
    popup_setoptions(pum_winid, { cursorline: 0 <= kouho_index })
    Redraw()
  endif
enddef

def CloseKouho()
  MapSelectMode(false)
  ClosePum()
enddef
# }}}

# 連鎖補完 {{{
# 🧪様子見中
def RegisterToChainJisyo(next_word: string)
  if !!last_word && !!next_word
    chain_jisyo[last_word] = chain_jisyo->get(last_word, [])->insert(next_word)->Uniq()
  endif
  last_word = next_word
  end_pos = start_pos + next_word->len()
enddef

def ShowChainJisyo()
  if chain_jisyo->has_key(last_word)
    kouho = chain_jisyo[last_word]->AddDetail('入力履歴')
    kouho_index = -1
    PopupKouho('')
  endif
enddef
# }}}

# 辞書操作 {{{
def ToFullPathAndEncode(path: string): list<string>
  const m = path->matchlist('\(.\+\):\([a-zA-Z0-9-]*\)$')
  return !m ? [expand(path), ''] : [expand(m[1]), m[2]]
enddef

def IconvTo(str: string, enc: string): string
  return (!str || !enc || enc ==# &enc) ? str : str->iconv(&enc, enc)
enddef

def IconvFrom(str: string, enc: string): string
  return (!str || !enc || enc ==# &enc) ? str : str->iconv(enc, &enc)
enddef

def ReadJisyo(path: string): dict<any>
  # キャッシュ済み
  if jisyo->has_key(path)
    return jisyo[path]
  endif
  # 読み込んでスクリプトローカルにキャッシュする
  const [p, enc] = ToFullPathAndEncode(path)
  if !filereadable(p)
    # 後から辞書ファイルを置かれる可能性があるので、キャッシュしない
    return { lines: [], enc: enc }
  endif
  # iconvはWindowsですごく重いので、読み込み時には全体を変換しない
  # 検索時に検索対象の方の文字コードを辞書にあわせる
  jisyo[path] = { lines: readfile(p)->sort(), enc: enc }
  return jisyo[path]
enddef

def WriteJisyo(lines: list<string>, path: string, flags: string = '')
  const [p, _] = ToFullPathAndEncode(path)
  writefile(lines, p, flags)
enddef

export def RegisterToUserJisyo(key: string): list<string>
  if is_registering_user_jisyo
    return []
  endif
  is_registering_user_jisyo = true
  const save = {
    mode_id: mode.id,
    skkmode: skkmode,
    start_pos: start_pos,
    end_pos: end_pos,
    okuri: okuri,
  }
  var result = []
  try
    SetSkkMode(skkmode_direct)
    autocmd vim9skk CmdlineEnter * ++once ShowMode(false)
    const value = input($'ユーザー辞書に登録({key}): ')->trim()
    if !value
      echo 'キャンセルしました'
    else
      # ユーザー辞書に登録する
      const newline = $'{key} /{value}/'
      var j = ReadJisyo(g:vim9skk.jisyo_user)
      jisyo[g:vim9skk.jisyo_user] = j # ユーザー辞書ファイルが無い場合に備えてキャッシュを上書きする
      jisyo[g:vim9skk.jisyo_user].lines += [newline->IconvTo(j.enc)]
      [newline]->WriteJisyo(g:vim9skk.jisyo_user, 'a')
      result += [value]
      echo '登録しました'
    endif
  finally
    SetMode(save.mode_id)
    SetSkkMode(save.skkmode)
    start_pos = save.start_pos
    end_pos = save.end_pos
    okuri = save.okuri
    is_registering_user_jisyo = false
  endtry
  return result
enddef

def ReadRecentJisyo(): dict<any>
  if !recent_jisyo
    const [p, enc] = ToFullPathAndEncode(g:vim9skk.jisyo_recent)
    if !filereadable(p)
      return { lines: [], enc: enc }
    endif
    recent_jisyo = { lines: readfile(p), enc: enc }
  endif
  return recent_jisyo
enddef

def RegisterToRecentJisyo(before: string, after: string)
  if !before || !after
    return
  endif
  # 新規に追加する行
  const afters = GetKouhoFromJisyo(g:vim9skk.jisyo_recent, before)
    ->insert(after)
    ->Uniq()
    ->join('/')
  const newline = $'{before} /{afters}/'
  # 既存の行を削除してから先頭に追加する
  var j = ReadRecentJisyo()
  const head = $'{before} '->IconvTo(j.enc)
  j.lines = j.lines # 再代入しないとだめ？？
    ->filter((_, v) => !v->StartsWith(head))
    ->slice(0, g:vim9skk.recent)
    ->insert(newline->IconvTo(j.enc))
  # 候補探索用の辞書にはソート済のものをセットする
  jisyo[g:vim9skk.jisyo_recent] = { lines: j.lines->copy()->sort(), enc: j.enc }
enddef

def SaveRecentJisyo()
  var lines = ReadRecentJisyo().lines
  if !!lines
    lines->WriteJisyo(g:vim9skk.jisyo_recent)
  endif
enddef

export def RefreshJisyo()
  jisyo = {}
  echo '辞書をリフレッシュしました'
enddef
# }}}

# terminal {{{
export def TerminalInput()
  autocmd CmdlineEnter * ++once Enable()
  const value = input($'terminalに入力: ')->trim()
  if !!value
    feedkeys(value, 'int')
  endif
enddef
# }}}

