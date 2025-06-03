vim9script

# スクリプトローカル変数 {{{
const MODE_HIRA = 1
const MODE_KATA = 2
const MODE_HANK = 3
const MODE_ALPH = 4
const MODE_ABBR = 5

const SKKMODE_DIRECT = 0
const SKKMODE_MIDASI = 1
const SKKMODE_SELECT = 2

const POPUPWIN_KIND_NONE = 0
const POPUPWIN_KIND_MODE = 1
const POPUPWIN_KIND_KOUHO = 2

var initialized = false
var mode = { id: MODE_HIRA, use_roman: true, items: [] }
var skkmode = SKKMODE_DIRECT
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
var popupwin_winid = 0
var popupwin_kind = POPUPWIN_KIND_NONE
var popupwin_midasi = 0
var popupwin_midasi_update_timer = 0
var popupwin_midasi_pos = {}
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
  ' !"#$%&''()-^\@[;:],./\=~|`{+*}<>?_')->split('.\zs')
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

def GetPopupWinPos(d: number = 1): any
  var pp = {}
  if mode() ==# 'c'
    const p = getcmdscreenpos()
    pp = {
      col: p % &columns,
      line: &lines + p / &columns - d - &cmdheight + 1,
    }
  else
    const c = getcurpos()
    const p = screenpos(0, c[1], c[2])
    pp = {
      col: p.col,
      line: min([p.row + d, &lines]),
    }
  endif
  pp = g:vim9skk.change_popuppos(pp)
  return {
    pos: 'topleft',
    col: pp.col,
    line: pp.line,
    wrap: false,
  }
enddef

export def NoChangePopupPos(popup_pos: any): any
  return popup_pos
enddef

# }}}

# 表示制御 {{{
def ClosePopupWin()
  if !!popupwin_winid
    popup_close(popupwin_winid)
    popupwin_winid = 0
    popupwin_kind = POPUPWIN_KIND_NONE
    kouho_index = -1
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
    # Note:
    # 確定時の<BS>によるカーソル移動で発火すると色々面倒なのでSafeStateを挟む
    autocmd CursorMovedI,CursorMovedC * autocmd SafeState * ++once FollowCursorModePopupWin()
    autocmd ColorScheme * ColorScheme()
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
  SetMode(MODE_HIRA)
  ColorScheme()
  initialized = true
enddef

def ColorScheme()
  silent! hi default vim9skkMidasi cterm=underline gui=underline
  silent! hi default link vim9skkModeOff PmenuExtra
  silent! hi default link vim9skkModeHira PmenuSel
  silent! hi default link vim9skkModeKata PmenuMatchSel
  silent! hi default link vim9skkModeHankaku Pmenu
  silent! hi default link vim9skkModeAlphabet Pmenu
  silent! hi default link vim9skkModeAbbr Pmenu
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
  RunOnMidasi()
  PopupMode()
  DoUserEvent('Vim9skkModeChanged')
  DoUserEvent('Vim9skkEnter')
enddef

export def Disable(popup_even_off: bool = true): string
  if !g:vim9skk_enable
    return ''
  endif
  if skkmode !=# SKKMODE_DIRECT
    Complete()->feedkeys('nit')
    ToDirectMode()
  endif
  g:vim9skk_enable = false
  UnmapAll()
  CloseKouho()
  PopupMode()
  DoUserEvent('Vim9skkModeChanged')
  DoUserEvent('Vim9skkLeave')
  return ''
enddef

export def ToggleSkk()
  if g:vim9skk_enable && !mode.use_roman
    SetMode(MODE_HIRA)
  elseif g:vim9skk_enable
    Disable()
  else
    Enable()
  endif
enddef

def OnInsertEnter()
  if g:vim9skk_enable
    PopupMode()
  endif
enddef

def OnInsertLeavePre()
  if !g:vim9skk_enable
    return
  endif
  CloseKouho()
  if skkmode ==# SKKMODE_DIRECT
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
    PopupMode()
  elseif getcmdtype() ==# ':'
    Disable(false)
  else
    ClosePopupWin()
    redraw
  endif
  if g:vim9skk_enable
    ToDirectMode()
    RunOnMidasi()
  endif
enddef

def OnCmdlineLeavePre()
  if g:vim9skk_enable
    ToDirectMode()
    CloseKouho()
    TurnOffAbbr()
  endif
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
  if m ==# MODE_HIRA
    return {
      id: MODE_HIRA,
      label: g:vim9skk.mode_label.hira,
      use_roman: true,
      items: roman_table_items,
      hi: 'vim9skkModeHira',
    }
  elseif m ==# MODE_KATA
    return {
      id: MODE_KATA,
      label: g:vim9skk.mode_label.kata,
      use_roman: true,
      items: roman_table_items
        ->ToItems((i) => [i[0], i[1]->ConvChars(hira_chars, kata_chars)]),
      hi: 'vim9skkModeKata',
    }
  elseif m ==# MODE_HANK
    return {
      id: MODE_HANK,
      label: g:vim9skk.mode_label.hankaku,
      use_roman: true,
      items: roman_table_items
        ->ToItems((i) => [i[0], i[1]->ConvChars(hira_chars, hankaku_chars)]),
      hi: 'vim9skkModeHankaku',
    }
  elseif m ==# MODE_ALPH
    return {
      id: MODE_ALPH,
      label: g:vim9skk.mode_label.alphabet,
      use_roman: false,
      items: abbr_chars
        ->ToItems((i) => [i, i->ConvChars(abbr_chars, alphabet_chars)]),
      hi: 'vim9skkModeAlphabet',
    }
  else
    return {
      id: MODE_ABBR,
      label: g:vim9skk.mode_label.abbr,
      use_roman: false,
      items: abbr_chars->ToItems((i) => [i, i]),
      hi: 'vim9skkModeAbbr',
    }
  endif
enddef

def SetMode(m: number)
  mode = GetModeSettings(m)
  MapDirectMode()
  if skkmode !=# SKKMODE_SELECT
    PopupMode()
  endif
  silent! doautocmd User Vim9skkModeChanged
enddef

def ToDirectMode(chain: string = '', delta: number = 0): string
  SetSkkMode(SKKMODE_DIRECT)
  start_pos = GetPos() - delta
  return chain
enddef

def RunOnMidasi(chain: string = ''): string
  if g:vim9skk.run_on_midasi
    U('')
  endif
  return chain
enddef

def SetSkkMode(s: number)
  if skkmode !=# s
    skkmode = s
    g:vim9skk_midasi = ''
    MapMidasiMode()
    if s ==# SKKMODE_MIDASI
      PopupMode()
      PopupColoredMidasi()
    else
      CloseColoredMidasi()
    endif
  endif
enddef

def ToggleMode(m: number): string
  var target = ''
  if skkmode ==# SKKMODE_MIDASI
    target = GetTarget()
    if !target
      ToDirectMode()
    endif
  endif
  # 基本はカタカナモードにするだけ
  if skkmode ==# SKKMODE_DIRECT
    SetMode(mode.id !=# m ? m : MODE_HIRA)
    return ''
  endif
  # 見出しや選択中ならカタカナに変換して確定する
  CloseKouho()
  const k_chars = m ==# MODE_KATA ? kata_chars : hankaku_chars
  const mm = GetModeSettings(m)
  const before = target->RemoveMarker()
  const after = before
    ->SwapChars(hira_chars, k_chars)
    ->ConvChars(kata_chars, k_chars)
    ->SwapChars(alphabet_chars, abbr_chars)
  RegisterToRecentJisyo(before, after)
  return after
    ->ReplaceTarget()
    ->ToDirectMode()
    ->RunOnMidasi()
    ->PopupMode()
enddef

def ToggleAbbr(): string
  if mode.id ==# MODE_ABBR
    TurnOffAbbr()
    if skkmode ==# SKKMODE_MIDASI || skkmode ==# SKKMODE_SELECT
      return Complete()
    endif
    TurnOffAbbr()
    return ''
  elseif skkmode ==# SKKMODE_MIDASI
    SetMode(MODE_ABBR)
    return ''
  elseif skkmode ==# SKKMODE_SELECT
    const c = Complete()
    SetMode(MODE_ABBR)
    return c .. SetMidasi()
  else
    SetMode(MODE_ABBR)
    return SetMidasi()
  endif
enddef

def TurnOffAbbr(): string
  if mode.id ==# MODE_ABBR
    UnmapAll()
    SetMode(MODE_HIRA)
  endif
  return ''
enddef
# }}}

# 入力モードをポップアップ {{{
def PopupMode(s: string = ''): string
  g:vim9skk_mode = g:vim9skk_enable
    ? skkmode ==# SKKMODE_MIDASI && mode.id !=# MODE_ABBR
    ? g:vim9skk.mode_label.midasi
    : mode.label
    : g:vim9skk.mode_label.off
  ClosePopupWin()
  if !g:vim9skk_mode
    redraw
    return s
  endif
  var a = GetPopupWinPos()
  if !g:vim9skk_enable
    a.time = g:vim9skk.mode_label_timeout
  endif
  a.highlight = g:vim9skk_enable ? mode.hi : 'vim9skkModeOff'
  popupwin_winid = popup_create(g:vim9skk_mode, a)
  popupwin_kind = POPUPWIN_KIND_MODE
  redraw
  return s
enddef

def FollowCursorModePopupWin()
  if !popupwin_winid || popupwin_kind !=# POPUPWIN_KIND_MODE || !g:vim9skk_enable
    return
  endif
  if skkmode ==# SKKMODE_MIDASI && !!start_pos
      const p = GetPos()
      if p < start_pos
        SetMidasi()
        FixPosColoredMidasi()
      endif
  endif
  popup_move(popupwin_winid, GetPopupWinPos())
enddef
# }}}

# 変換対象を色付け {{{
# TODO: 画面右端で表示がおかしい
def PopupColoredMidasi()
  if !popupwin_midasi
    popupwin_midasi_pos = GetPopupWinPos(0)
    popupwin_midasi_pos.highlight = 'vim9skkMidasi'
    popupwin_midasi = popup_create('', popupwin_midasi_pos)
  endif
  if !!popupwin_midasi_update_timer
    timer_stop(popupwin_midasi_update_timer)
  endif
  popupwin_midasi_update_timer = timer_start(20, UpdateColoredMidasi, { repeat: - 1 })
enddef

def FixPosColoredMidasi()
  if !!popupwin_midasi
    popupwin_midasi_pos = GetPopupWinPos(0)
    popupwin_midasi_pos.highlight = 'vim9skkMidasi'
    popup_move(popupwin_midasi, popupwin_midasi_pos)
  endif
enddef

def CloseColoredMidasi()
  if !!popupwin_midasi
    popup_close(popupwin_midasi)
    popupwin_midasi = 0
    timer_stop(popupwin_midasi_update_timer)
    popupwin_midasi_update_timer = 0
  endif
enddef

var latest_target = ''
def UpdateColoredMidasi(timer: number)
  if !!popupwin_midasi
    const t = GetTarget()
    if !!t
      popup_show(popupwin_midasi)
      popup_settext(popupwin_midasi, GetTarget())
    else
      popup_hide(popupwin_midasi)
    endif
    if latest_target !=# t
      if !t
        PopupMode()
      else
        ShowRecent(t)
      endif
      latest_target = t
    endif
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
    if !key
      # nop
    elseif enable
      # 選択モードのxや全英モードのLに対応するための面倒なif文
      if skkmode ==# SKKMODE_SELECT || mode.use_roman || abbr_chars->Excludes(key)
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
  MapFunction(g:vim9skk.keymap.disable,  'Disable()')
  MapFunction(g:vim9skk.keymap.kata,     'ToggleMode(MODE_KATA)')
  MapFunction(g:vim9skk.keymap.hankaku,  'ToggleMode(MODE_HANK)')
  MapFunction(g:vim9skk.keymap.alphabet, 'ToggleMode(MODE_ALPH)')
  MapFunction(g:vim9skk.keymap.abbr,     'ToggleAbbr()')
  MapFunction(g:vim9skk.keymap.midasi,   'U("")') # 大文字を押したのと同じ
  # leximaなどがinsertモードを解除してしまうので…
  noremap! <buffer> <script> <BS> <BS>
enddef

def MapRoman()
  if mode.use_roman
    for key in abbr_chars
      const k = key->EscapeForMap()
      silent! execute $'unmap! <buffer> <script> {k}'
    endfor
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
    # Note: feedkeysだとwindowsで`せ`が文字化けする
    execute $'{map} <buffer> <expr> <script> {k} vim9skk#L("{v}")'
  endfor
enddef

def MapMidasiMode()
  if g:vim9skk_enable
    const enable = skkmode !=# SKKMODE_DIRECT &&
      (skkmode !=# SKKMODE_MIDASI || !!g:vim9skk_midasi)
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
export def L(chain: string): string
  var prefix = ''
  if skkmode ==# SKKMODE_SELECT
    prefix = Complete()
  elseif skkmode ==# SKKMODE_MIDASI
    GetTarget()
      ->Split(g:vim9skk.marker_okuri)[0]
      ->RemoveMarker()
      ->AddStr(chain)
      ->ShowRecent()
  endif
  if !kouho
    PopupMode()
  endif
  var v = chain
  if mode.use_roman  && v =~# '[a-z]$'
    feedkeys(v[-1], 'it')
    v = v[ : -2]
  endif
  return prefix .. v .. "\<ScriptCmd>vim9skk#MidasiInput()\<CR>"
enddef

# 大文字入力時(Upper)
def U(key: string): string
  # 選択モードなら確定する
  var comp = ''
  if skkmode ==# SKKMODE_SELECT
    comp = Complete()
  endif
  # 直接入力なら見出しモードへ遷移する
  const target = GetTarget()
  if skkmode ==# SKKMODE_DIRECT
    return comp .. SetMidasi(key)
  endif
  # 見出しモードなら…
  var prefix = ''
  const sion = target->matchstr('[a-z]*$')
  if !!sion && !!key
    # Shift押しっぱなしでもローマ字入力できるように頑張る
    prefix = repeat("\<BS>", sion->len()) .. sion
  elseif !!target && target->stridx(g:vim9skk.marker_okuri) ==# -1
    # 送り仮名マーカーを設置する
    prefix = g:vim9skk.marker_okuri
    # Note: <BS>などでマーカーが削除されることを考慮すると、送り仮名の位置を内部的に持つのは難しかった…
  endif
  return prefix .. key->tolower()
enddef

def SetMidasi(key: string = '', delta: number = 0): string
  SetSkkMode(SKKMODE_MIDASI)
  const next_start_pos = GetPos() - delta
  const next_word = GetLine()->matchstr($'\%{end_pos}c.*\%{next_start_pos}c')
  if !!next_word
    RegisterToChainJisyo(next_word)
  endif
  start_pos = next_start_pos
  return key->tolower()
enddef

export def MidasiInput()
  if skkmode ==# SKKMODE_MIDASI
    g:vim9skk_midasi = GetTarget()
    MapMidasiMode()
    DoUserEvent('Vim9skkMidasiInput')
  endif
enddef

def SetPrefix(): string
  if skkmode ==# SKKMODE_SELECT
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
    ->substitute(g:vim9skk.marker_okuri, '', '')
enddef

def ReplaceTarget(after: string): string
  return "\<BS>"->repeat(strchars(GetTarget())) .. after
enddef

def StartSelect(chain: string = ''): string
  if skkmode ==# SKKMODE_SELECT
    return Select(1)
  endif
  const target = GetTarget()
  if !target
    return chain
  endif
  target->GetAllKouho()
  if !kouho
    CloseKouho()
    return ''
  endif
  SetSkkMode(SKKMODE_SELECT)
  PopupKouho(1)
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
  SetSkkMode(SKKMODE_SELECT)
  kouho_index = Cyclic(kouho_index + d, len(kouho))
  HighlightKouho()
  return ReplaceTarget($'{GetSelectedKouho()}{okuri}')
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
  kouho = []
  henkan_key = ''
  ClosePopupWin()
  TurnOffAbbr()
  return chain ..
    after
      ->ReplaceTarget()
      ->AddLeftForParen(after)
      ->ToDirectMode(pos_delta)
      ->AfterComplete()
      ->RunOnMidasi()
enddef

def AfterComplete(chain: string): string
  ShowChainJisyo()
  if !kouho
    CloseKouho()
    PopupMode()
  endif
  return chain
enddef
# }}}

# 候補をポップアップ {{{
def PopupKouho(default: number = 0)
  MapSelectMode(!!kouho)
  ClosePopupWin()
  if !kouho
    redraw
    return
  endif
  if g:vim9skk.popup_maxheight <= 0
    return
  endif
  const target = GetTarget()
  const sp = screenpos(0, line('.'), col('.'))
  var popupwin_options = {
    pos: 'topleft',
    col: popupwin_midasi_pos.col,
    line: sp.row + 1,
    cursorline: true,
    maxheight: g:vim9skk.popup_maxheight,
    wrap: false,
  }
  if mode() ==# 'c'
    popupwin_options.line = popupwin_midasi_pos.line - 1
    popupwin_options.pos = 'botleft'
  elseif &lines - g:vim9skk.popup_minheight < screenrow()
    popupwin_options.line = sp.row - 1
    popupwin_options.pos = 'botleft'
  endif
  var lines = []
  for k in kouho
    const l = k->substitute(';', "\t", '')
    lines += [l]
  endfor
  popupwin_winid = popup_create(lines, popupwin_options)
  popupwin_kind = POPUPWIN_KIND_KOUHO
  win_execute(popupwin_winid, 'setlocal tabstop=12')
  win_execute(popupwin_winid, 'syntax match PMenuExtra /\t.*/')
  if default
    kouho_index = default
  endif
  HighlightKouho()
enddef

def HighlightKouho()
  if popupwin_winid !=# 0
    win_execute(popupwin_winid, $':{kouho_index + 1}')
    popup_setoptions(popupwin_winid, { cursorline: 0 <= kouho_index })
    redraw
  endif
enddef

def CloseKouho()
  MapSelectMode(false)
  if popupwin_kind ==# POPUPWIN_KIND_KOUHO
    ClosePopupWin()
  endif
  redraw
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
    PopupKouho()
  endif
enddef
# }}}

# 連鎖補完をポップアップ {{{
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
    PopupKouho()
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

export def ReadJisyo(path: string): dict<any>
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
    popupwin_midasi_pos: popupwin_midasi_pos->deepcopy(),
  }
  var result = []
  try
    SetSkkMode(SKKMODE_DIRECT)
    autocmd vim9skk CmdlineEnter * ++once PopupMode()
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
    popupwin_midasi_pos = save.popupwin_midasi_pos
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
  recent_jisyo = {}
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

