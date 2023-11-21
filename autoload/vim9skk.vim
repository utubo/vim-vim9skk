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
var mode = mode_hira
var skkmode = skkmode_direct
var start_pos = 0
var henkan_key = ''
var okuri = ''
var kouho = []
var kouho_index = 0
var jisyo = {}
var jisyo_encode = {}
var popup_mode_id = 0
var popup_kouho_id = 0
var vim9skkmap = {}

const roman_table = {
  # 4文字
  ltsu: 'っ', xtsu: 'っ',
  # 3文字
  gya: 'ぎゃ', gyu: 'ぎゅ', gye: 'ぎぇ', gyo: 'ぎょ',
  zya: 'じゃ', zyu: 'じゅ', zye: 'じぇ', zyo: 'じょ',
  dya: 'ぢゃ', dyu: 'ぢゅ', dye: 'ぢぇ', dyo: 'ぢょ',
  dha: 'ぢゃ', dhu: 'ぢゅ', dhe: 'ぢぇ', dho: 'ぢょ',
  bya: 'びゃ', byu: 'びゅ', bye: 'びぇ', byo: 'びょ',
  pya: 'ぴゃ', pyu: 'ぴゅ', pye: 'ぴぇ', pyo: 'ぴょ',
  kya: 'きゃ', kyu: 'きゅ', kye: 'きぇ', kyo: 'きょ',
  sya: 'しゃ', syu: 'しゅ', sye: 'しぇ', syo: 'しょ',
  sha: 'しゃ', shi: 'し',   shu: 'しゅ', she: 'しぇ', sho: 'しょ',
  tya: 'ちゃ', tyu: 'ちゅ', tye: 'ちぇ', tyo: 'ちょ',
  cha: 'ちゃ', chi: 'ち',   chu: 'ちゅ', che: 'ちぇ', cho: 'ちょ',
  tha: 'てゃ', thi: 'てぃ', thu: 'てゅ', the: 'てぇ', tho: 'てょ',
  nya: 'にゃ', nyu: 'にゅ', nye: 'にぇ', nyo: 'にょ',
  hya: 'ひゃ', hyu: 'ひゅ', hye: 'ひぇ', hyo: 'ひょ',
  mya: 'みゃ', myu: 'みゅ', mye: 'みぇ', myo: 'みょ',
  rya: 'りゃ', ryu: 'りゅ', rye: 'りぇ', ryo: 'りょ',
  lya: 'ゃ', lyu: 'ゅ', lyo: 'ょ', ltu: 'っ', lwa: 'ゎ',
  xya: 'ゃ', xyu: 'ゅ', xyo: 'ょ', xtu: 'っ', xwa: 'ゎ',
  tsu: 'つ',
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
  a: 'あ', i: 'い', u: 'う', e: 'え', o: 'お',
  # 記号
  'z,': '・', 'z.': '…', 'z[': '「', 'z]': '」',
  zl: '→', zh: '←', zj: '↓', zk: '↑',
  '-': 'ー', '.': '。', ',': '、', '!': '！', '?': '？', '/': '・', '~': '～',
}
const roman_table_items = roman_table->items()

# {か:'k'}みたいなdict
# 変換時に「けんさく*する」→「けんさくs」というふうに辞書を検索する時に使う
# Init()で作る
var okuri_table = {}
# }}}

# ユーティリティー {{{
const hira_chars = ('ぁあぃいぅうぇえぉおかがきぎくぐけげこご' ..
  'さざしじすずせぜそぞただちぢっつづてでとど' ..
  'なにぬねのはばぱひびぴふぶぷへべぺほぼぽ' ..
  'まみむめもゃやゅゆょよらりるれろゎわゐゑをんゔー')->split('.\zs')

const kata_chars = ('ァアィイゥウェエォオカガキギクグケゲコゴ' ..
  'サザシジスズセゼソゾタダチヂッツヅテデトド' ..
  'ナニヌネノハバパヒビピフブプヘベペホボポ' ..
  'マミムメモャヤュユョヨラリルレロヮワヰヱヲンヴー')->split('.\zs')

const hankaku_chars = ('ｧｱｨｲｩｳｪｴｫｵｶｶﾞｷｷﾞｸｸﾞｹｹﾞｺｺﾞ' ..
  'ｻｻﾞｼｼﾞｽｽﾞｾｾﾞｿｿﾞﾀﾀﾞﾁﾁﾞｯﾂﾂﾞﾃﾃﾞﾄﾄﾞ' ..
  'ﾅﾆﾇﾈﾉﾊﾊﾞﾊﾟﾋﾋﾞﾋﾟﾌﾌﾞﾌﾟﾍﾍﾞﾍﾟﾎﾎﾞﾎﾟ' ..
  'ﾏﾐﾑﾒﾓｬﾔｭﾕｮﾖﾗﾘﾙﾚﾛﾜﾜｲｴｦﾝｳﾞｰ')->split('.[ﾟﾞ]\?\zs')

const alphabet_chars = ('０１２３４５６７８９' ..
  'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ' ..
  'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ' ..
  '　！＂＃＄％＆＇（）－＾＼＠［；：］，．／＼＝～｜｀｛＋＊｝＜＞？＿')->split('.\zs')

const abbr_chars = ('0123456789' ..
  'abcdefghijklmnopqrstuvwxyz' ..
  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ..
  ' !"#$%&''()-^\@[;:],./\=~|`{+*}<>?_')->split('.\zs')

# Init()で作る
var alphabet_table = {}

# tr()を使いたいけど、半角カナ濁点半濁点に対応しないといけないので自作
def ConvChars(str: string, from_chars: list<string>, to_chars: list<string>): string
  var dest = []
  for c in str->split('.\zs')
    const p = from_chars->index(c)
    dest += [p ==# - 1 ? c : to_chars[p]]
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
    if result->index(a) ==# -1
      result->add(a)
    endif
  endfor
  return result
enddef
# }}}

# 基本 {{{
def MapPlugKey(key: string, f: string)
  Map($'<script> <Plug>({key}) <ScriptCmd>{f}->feedkeys("nit")<CR>')
enddef

def Init()
  MapPlugKey('vim9skk-kana',     'ToggleMode(mode_kata)')
  MapPlugKey('vim9skk-hankaku',  'ToggleMode(mode_hankaku)')
  MapPlugKey('vim9skk-alphabet', 'ToggleMode(mode_alphabet)')
  MapPlugKey('vim9skk-abbr',     'ToggleAbbr()')
  MapPlugKey('vim9skk-hira',     'SetMode(mode_hira)')
  MapPlugKey('vim9skk-midasi',   'SetMidasi()')
  MapPlugKey('vim9skk-prev',     'Select(-1)')
  MapPlugKey('vim9skk-next',     'Select(1)')
  MapPlugKey('vim9skk-cancel',   'Select(-kouho_index)')
  augroup vim9skk
    autocmd!
    autocmd BufEnter * MapToBuf()
    autocmd InsertEnter * OnInsertEnter()
    autocmd InsertLeave * OnInsertLeave()
    autocmd CmdlineEnter * OnCmdlineEnter()
    autocmd CmdlineLeave * CloseKouho()
    autocmd VimLeave * SaveRecentlies()
  augroup END
  for [k, v] in roman_table_items
    okuri_table[v->strcharpart(0, 1)] = k[0]
  endfor
  for i in alphabet_chars->len()->range()
    alphabet_table[alphabet_chars[i]] = abbr_chars[i]
  endfor
  okuri_table['っ'] = 'r'
  SetMode(mode_hira)
  initialized = true
enddef

def ToDirectMode(s: string = ''): string
  skkmode = skkmode_direct
  start_pos = GetPos()
  CloseKouho()
  return s
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
  if mode ==# mode_abbr || mode ==# mode_alphabet
    SetMode(mode_hira)
    # ↓SetModeで実行しているのでここでは不要
    #silent! doautocmd User Vim9skkModeChanged
  else
    ShowMode(true)
    silent! doautocmd User Vim9skkModeChanged
  endif
  silent! doautocmd User Vim9skkEnabled
enddef

export def Disable(popup_even_off: bool = true)
  if skkmode !=# skkmode_direct
    const target = GetTarget()
    if !!target
      Complete()->feedkeys('nit')
    endif
  endif
  g:vim9skk_enable = false
  UnmapAll()
  ShowMode(popup_even_off)
  silent! doautocmd User Vim9skkModeChanged
  silent! doautocmd User Vim9skkDisbaled
enddef

export def ToggleSkk(): string
  if g:vim9skk_enable
    if mode ==# mode_abbr || mode ==# mode_alphabet
      SetMode(mode_hira)
    else
      Disable()
    endif
  else
    Enable()
  endif
  return ''
enddef

def SetMode(m: number): string
  mode = m
  MapToBuf()
  if skkmode !=# skkmode_select
    CloseKouho()
  endif
  ShowMode(true)
  silent! doautocmd User Vim9skkModeChanged
  return ''
enddef

def ShowMode(popup_even_off: bool)
  if !g:vim9skk_enable
    g:vim9skk_mode = g:vim9skk.mode_label.off
  elseif mode ==# mode_kata
    g:vim9skk_mode = g:vim9skk.mode_label.kata
  elseif mode ==# mode_hankaku
    g:vim9skk_mode = g:vim9skk.mode_label.hankaku
  elseif mode ==# mode_alphabet
    g:vim9skk_mode = g:vim9skk.mode_label.alphabet
  elseif mode ==# mode_abbr
    g:vim9skk_mode = g:vim9skk.mode_label.abbr
  else
    g:vim9skk_mode = g:vim9skk.mode_label.hira
  endif
  CloseModePopup()
  if 0 < g:vim9skk.mode_label_timeout && (popup_even_off || g:vim9skk_enable)
    popup_mode_id = popup_create(g:vim9skk_mode, {
      col: mode() ==# 'c' ? getcmdscreenpos() : 'cursor',
      line: mode() ==# 'c' ? (&lines - 1) : 'cursor+1',
      time: g:vim9skk.mode_label_timeout,
    })
    redraw
  endif
enddef

def CloseModePopup()
  if !!popup_mode_id
    popup_close(popup_mode_id)
    popup_mode_id = 0
    redraw
  endif
enddef

def OnInsertEnter()
  ShowMode(false)
enddef

def OnInsertLeave()
  if skkmode !=# skkmode_direct
    const target = GetTarget()
    setline('.', getline('.')->substitute(
      $'\%{start_pos}c{"."->repeat(strchars(target))}',
      target->RemoveMarker(),
      ''
    ))
    ToDirectMode()
  endif
enddef

def OnCmdlineEnter()
  # '@'も含めたいがredrawでecho出力がクリアされてしまう
  if getcmdtype() =~# '[/?]'
    ShowMode(false)
  elseif getcmdtype() ==# ':'
    Disable(false)
  else
    CloseModePopup()
  endif
enddef
# }}}

# キー入力 {{{
def Map(m: string)
  execute $'map! {m}'
enddef

export def Vim9skkMap(m: string)
  var key = ''
  for a in m->split('\\\@<! ')
    if a ==# '<script>'
      echoe 'Vim9skkMapでは<script>は使用できません'
    endif
    if ['<buffer>', '<nowait>', '<silent>', '<special>', '<script>', '<expr>', '<unique>']->index(a) ==# -1
      key = a
      break
    endif
  endfor
  vim9skkmap[key] = m
enddef

def EscapeForMap(key: string): string
  return key
    ->substitute('<', '<LT>', 'g')
    ->substitute('|', '<Bar>', 'g')
    ->substitute(' ', '<Space>', 'g')
    ->substitute('\', '<Bslash>', 'g')
enddef

var mode_settings = {}
def GetModeSettings(m: number): any
  if mode_settings->has_key(m)
    return mode_settings[m]
  endif
  var s = { use_roman: false, items: [] }
  var table = {}
  if m ==# mode_hira
    s.use_roman = true
    table = roman_table
  elseif m ==# mode_kata
    s.use_roman = true
    for [k, v] in roman_table_items
      table[k] = v->ConvChars(hira_chars, kata_chars)
    endfor
  elseif m ==# mode_hankaku
    s.use_roman = true
    for [k, v] in roman_table_items
      table[k] = v->ConvChars(hira_chars, hankaku_chars)
    endfor
  elseif m ==# mode_alphabet
    for i in abbr_chars
      table[i] = i->ConvChars(abbr_chars, alphabet_chars)
    endfor
  elseif m ==# mode_abbr
    for i in abbr_chars
      table[i] = i
    endfor
  endif
  s.items = table->items()
  mode_settings[m] = s
  return s
enddef

# <buffer>にマッピングしないと他のプラグインに取られちゃう
def MapToBuf()
  if !g:vim9skk_enable
    return
  endif
  if get(b:, 'vim9skk_keymapped', 0) ==# mode
    return
  endif
  UnmapAll()
  b:vim9skk_saved_keymap = maplist()->filter((_, m) => m.buffer)
  b:vim9skk_keymapped = mode
  const s = GetModeSettings(mode)
  for [key, value] in s.items
    const k = key->EscapeForMap()
    const c = key->escape('"|\\')
    const v = value->escape('"|\\')
    Map($'<buffer> <script> {k} <ScriptCmd>I("{c}", "{v}")->feedkeys("it")<CR>')
  endfor
  if s.use_roman
    for key in 'ABCDEFGHIJKMNOPRSTUVWXYZ'->split('.\zs')
      const k = key->EscapeForMap()
      const c = key->escape('"|\\')
      Map($'<buffer> <script> <nowait> {k} <ScriptCmd>SetMidasi("{c}")->feedkeys("it")<CR>')
    endfor
  endif
  for [_, m] in vim9skkmap->items()
    Map($'<buffer> {m}')
  endfor
  if mode !=# mode_alphabet
    Map('<buffer> <script> <Space> <ScriptCmd>OnSpace()->feedkeys("nit")<CR>')
    Map('<buffer> <script> <CR> <ScriptCmd>OnCR()->feedkeys("nit")<CR>')
  endif
enddef

def UnmapAll()
  if !get(b:, 'vim9skk_keymapped', 0)
    return
  endif
  b:vim9skk_keymapped = 0
  for m in maplist()->filter((_, m) => m.script) + vim9skkmap->keys()
    silent! execute $'unmap! <buffer> <script> {m.lhs->EscapeForMap()}'
  endfor
  if !!get(b:, 'vim9skk_saved_keymap', {})
    for m in b:vim9skk_saved_keymap
      mapset(m)
    endfor
    b:vim9skk_saved_keymap = {}
  endif
enddef

def I(c: string, after: string): string
  var prefix = ''
  if skkmode ==# skkmode_select
    if c ==# 'x'
      return Select(-1)
    endif
    prefix = Complete()
  endif
  if skkmode ==# skkmode_midasi
    GetTarget()
      ->substitute($'^{g:vim9skk.marker_midasi}\|^{g:vim9skk.marker_select}', '', '')
      ->AddStr(after)
      ->ShowRecent()
  endif
  return prefix .. after
enddef

def SetMidasi(c: string = ''): string
  if skkmode ==# skkmode_midasi
    if GetTarget() =~# g:vim9skk.marker_midasi
      return '*' .. c->tolower()
    endif
  endif
  var prefix = ''
  if skkmode ==# skkmode_select
    return Complete() .. c
  endif
  skkmode = skkmode_midasi
  start_pos = GetPos()
  return prefix .. g:vim9skk.marker_midasi .. c->tolower()
enddef

def OnSpace(): string
  if skkmode ==# skkmode_midasi
    return StartSelect()
  elseif skkmode ==# skkmode_select
    return Select(1)
  elseif mode ==# mode_abbr || mode ==# mode_hankaku
    return ' '
  elseif (mode ==# mode_hira || mode ==# mode_kata) &&
    GetLine()->matchstr($'.\?.\%{GetPos()}c') ==# 'z'
    return "\<BS>　"
  else
    return g:vim9skk.space
  endif
enddef

def OnCR(): string
  if skkmode !=# skkmode_direct
    return Complete()
  else
    return "\<CR>"
  endif
enddef

def ToggleMode(m: number): string
  if skkmode !=# skkmode_direct
    const before = GetTarget()->RemoveMarker()
    const after = before
      ->SwapChars(hira_chars, kata_chars)
      ->SwapChars(alphabet_chars, abbr_chars)
    RegisterToRecentJisyo(before, after)
    return after->ReplaceTarget()->ToDirectMode()
  else
    SetMode(mode !=# m ? m : mode_hira)
    return ''
  endif
enddef

def ToggleAbbr(): string
  if mode ==# mode_abbr
    SetMode(mode_hira)
    return ''
  else
    SetMode(mode_abbr)
    return SetMidasi()
  endif
enddef
#}}}

# 変換 {{{
def GetTarget(): string
  return GetLine()->matchstr($'\%{start_pos}c.*\%{GetPos()}c')
enddef

def RemoveMarker(s: string): string
  const result = s
    ->substitute(g:vim9skk.marker_midasi, '', '')
    ->substitute(g:vim9skk.marker_select, '', '')
    ->substitute('*', '', '')
  return result
enddef

def ReplaceTarget(after: string): string
  return "\<BS>"->repeat(strchars(GetTarget())) .. after
enddef

def StartSelect(): string
  var target = GetTarget()
  if mode ==# mode_hira || mode ==# mode_kata
    target = target->substitute('n$', 'ん', '')
  endif
  GetAllKouho(target)
  if !kouho
    CloseKouho()
    return ''
  endif
  skkmode = skkmode_select
  kouho_index = 0
  PopupKouho()
  return Select(1)
enddef

def GetKouhoFromJisyo(path: string, key: string): list<string>
  const [lines, enc] = ReadJisyo(path)
  const head = $'{key} '->IconvTo(enc)
  const max = len(lines) - 1
  if max < 0
    return []
  endif
  var limit = g:vim9skk.search_limit
  var d = max
  var i = max / 2
  while !!limit
    limit -= 1
    const line = lines[i]
    if line->StartsWith(head)
      var result = []
      for k in line->IconvFrom(enc)->Split(' ')[1]->split('/')
        result->add(k->substitute(';.*$', '', ''))
      endfor
      return result
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
    return
  endif
  # `▽ほげ*ふが`を見出しと送り仮名に分割する
  const [midasi, o] = target
    ->substitute(g:vim9skk.marker_midasi, '', '')
    ->ConvChars(kata_chars, hira_chars)
    ->Split('*')
  okuri = o
  # 候補を検索する
  henkan_key = $'{midasi}{okuri_table->get(okuri->matchstr('^.'), '')}' # `ほげf`
  kouho = [midasi]
  for path in [g:vim9skk.jisyo_recent, g:vim9skk.jisyo_user] + g:vim9skk.jisyo
    kouho += GetKouhoFromJisyo(path, henkan_key)
  endfor
  if len(kouho) ==# 1
    kouho = RegisterToUserJisyo(henkan_key)
  endif
  kouho = kouho->Uniq()
enddef

def Cyclic(a: number, max: number): number
  return (a + max) % max
enddef

def Select(d: number): string
  if skkmode ==# skkmode_midasi && !!kouho
    # 予測変換が表示されている場合、そのまま選択モードに移行する
    skkmode = skkmode_select
  elseif skkmode !=# skkmode_select
    return StartSelect()
  endif
  kouho_index = Cyclic(kouho_index + d, len(kouho))
  const after = g:vim9skk.marker_select .. kouho[kouho_index] .. okuri
  HighlightKouho()
  return ReplaceTarget(after)
enddef

def AddLeftForParen(p: string): string
  if g:vim9skk.parens->index(p) !=# -1
    return p .. "\<Left>"
  else
    return p
  endif
enddef

def Complete(): string
  RegisterToRecentJisyo(henkan_key, kouho->get(kouho_index, ''))
  kouho = []
  return GetTarget()
    ->RemoveMarker()
    ->AddLeftForParen()
    ->ReplaceTarget()
    ->ToDirectMode()
enddef
#}}}

# 予測変換ポップアップ {{{
def ShowRecent(_target: string): string
  var target = _target
  if mode ==# mode_hira || mode ==# mode_kata
    target = target->substitute('n$', 'ん', '')
  endif
  kouho = [target]
  const [lines, enc] = ReadJisyo(g:vim9skk.jisyo_recent)
  const head = target->IconvTo(enc)
  for j in lines
    if j->StartsWith(head)
      kouho += j->IconvFrom(enc)->Split(' ')[1]->split('/')
    endif
  endfor
  if 1 < len(kouho)
    kouho = kouho->Uniq()
    kouho_index = 0
    okuri = ''
    PopupKouho()
  endif
  return ''
enddef
#}}}

# 候補ポップアップ {{{
def PopupKouho()
  CloseKouho()
  if !kouho
    return
  endif
  g:vim9skk_selectable = true
  if g:vim9skk.popup_maxheight <= 0
    return
  endif
  CloseModePopup()
  popup_kouho_id = popup_create(kouho, {
      cursorline: true,
      maxheight: g:vim9skk.popup_maxheight
    }->extend(
      mode() ==# 'c' ? {
        col: getcmdscreenpos(),
        line: (&lines - 1),
        pos: 'botright',
      } : {
        col: 'cursor',
        line: 'cursor+1',
        pos: 'topright',
    })
  )
  HighlightKouho()
enddef

def HighlightKouho()
  if popup_kouho_id !=# 0
    win_execute(popup_kouho_id, $':{kouho_index + 1}')
    redraw
  endif
enddef

def CloseKouho()
  g:vim9skk_selectable = false
  if popup_kouho_id !=# 0
    popup_close(popup_kouho_id)
    popup_kouho_id = 0
    redraw
  endif
enddef
#}}}

# 辞書操作 {{{
def ToFullPathAndEncode(path: string): list<string>
  const m = path->matchlist('\(.\+\):\([a-zA-Z0-9-]\+\)$')
  return !m ? [expand(path), ''] : [expand(m[1]), m[2]]
enddef

def IconvTo(str: string, enc: string): string
  if !str || !enc || enc ==# &enc
    return str
  endif
  return str->iconv(&enc, enc)
enddef

def IconvFrom(str: string, enc: string): string
  if !str || !enc || enc ==# &enc
    return str
  endif
  return str->iconv(enc, &enc)
enddef

def ReadJisyo(path: string): list<any>
  # キャッシュ済み
  if jisyo->has_key(path)
    return [jisyo[path], get(jisyo_encode, path, '')]
  endif
  # 読み込んでスクリプトローカルにキャッシュする
  const [p, enc] = ToFullPathAndEncode(path)
  if !filereadable(p)
    return [[], enc]
  endif
  # iconvはWindowsですごく重いので、
  # 検索時に検索対象の方の文字コードを辞書にあわせる
  # var lines = readfile(p)->IconvFrom配列対応版(enc)
  var lines = readfile(p)
  lines->sort()
  jisyo[path] = lines
  jisyo_encode[path] = enc
  return [lines, enc]
enddef

def WriteJisyo(lines: list<string>, path: string, flags: string = '')
  const [p, _] = ToFullPathAndEncode(path)
  writefile(lines, p, flags)
enddef

export def RegisterToUserJisyo(key: string): list<string>
  const save_mode = mode
  const save_skkmode = skkmode
  const save_start_pos = start_pos
  const save_okuri = okuri
  var result = []
  try
    skkmode = skkmode_direct
    autocmd vim9skk CmdlineEnter * ++once ShowMode(false)
    const value = input($'ユーザー辞書に登録({key}): ')->trim()
    if !value
      echo 'キャンセルしました'
    else
      # ユーザー辞書に登録する
      const newline = $'{key} /{value}/'
      const [lines, enc] = ReadJisyo(g:vim9skk.jisyo_user)
      jisyo[g:vim9skk.jisyo_user] = lines + [newline->IconvTo(enc)]
      WriteJisyo([newline], expand(g:vim9skk.jisyo_user), 'a')
      echo '登録しました'
      result += [value]
    endif
  finally
    mode = save_mode
    skkmode = save_skkmode
    start_pos = save_start_pos
    okuri = save_okuri
  endtry
  return result
enddef

def RegisterToRecentJisyo(before: string, after: string)
  if !before || !after
    return
  endif
  # 新規に追加する行
  var afters = [after] + GetKouhoFromJisyo(g:vim9skk.jisyo_recent, before)
  const newline = $'{before} /{afters->Uniq()->join("/")}/'
  # 既存の行を削除してから先頭に追加する
  var [lines, enc] = ReadJisyo(g:vim9skk.jisyo_recent)
  const head = $'{before} '->IconvTo(enc)
  lines->filter((i, v) => !v->StartsWith(head))
  jisyo[g:vim9skk.jisyo_recent] = [newline->IconvTo(enc)] + lines[: g:vim9skk.recent]
enddef

def SaveRecentlies()
  var [lines, _] = ReadJisyo(g:vim9skk.jisyo_recent)
  if !!lines
    WriteJisyo(lines, g:vim9skk.jisyo_recent)
  endif
enddef

export def RefreshJisyo()
  jisyo = {}
  echo '辞書をリフレッシュしました'
enddef
#}}}

# terminal {{{
export def TerminalInput()
  autocmd CmdlineEnter * ++once Enable()
  const value = input($'terminalに入力: ')->trim()
  if !!value
    feedkeys(value, 'int')
  endif
enddef
#}}}

