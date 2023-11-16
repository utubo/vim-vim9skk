vim9script

# スクリプトローカル変数 {{{
const mode_hira = 0
const mode_kata = 1
const mode_hankaku = 2
const mode_alphabet = 3
const mode_abbr = 4

const skkmode_direct = 0
const skkmode_midasi = 1
const skkmode_select = 2

var initialized = false
var mode = mode_hira
var skkmode = skkmode_direct
var start_pos = 0
var pos_delta = 0 # 確定前後のカーソル位置の差
var henkan_key = ''
var okuri = ''
var kouho = []
var kouho_index = 0
var jisyo = {}
var popup_mode_id = 0
var popup_kouho_id = 0
var save_lmap = {}

const roma_table = [
  # 3文字
  ['gya', 'ぎゃ'], ['gyu', 'ぎゅ'], ['gyo', 'ぎょ'],
  ['zya', 'じゃ'], ['zyu', 'じゅ'], ['zyo', 'じょ'],
  ['dya', 'ぢゃ'], ['dyu', 'ぢゅ'], ['dyu', 'ぢぇ'], ['dyo', 'ぢょ'],
  ['dha', 'ぢゃ'], ['dhu', 'ぢゅ'], ['dhu', 'ぢぇ'], ['dho', 'ぢょ'],
  ['bya', 'びゃ'], ['byu', 'びゅ'], ['byo', 'びょ'],
  ['pya', 'ぴゃ'], ['pyu', 'ぴゅ'], ['pyo', 'ぴょ'],
  ['kya', 'きゃ'], ['kyu', 'きゅ'], ['kyo', 'きょ'],
  ['sya', 'しゃ'], ['syu', 'しゅ'], ['sye', 'しぇ'], ['syo', 'しょ'],
  ['sha', 'しゃ'], ['shu', 'しゅ'], ['she', 'しぇ'], ['sho', 'しょ'],
  ['tya', 'ちゃ'], ['tyu', 'ちゅ'], ['tyu', 'ちぇ'], ['tyo', 'ちょ'],
  ['cha', 'ちゃ'], ['chu', 'ちゅ'], ['chu', 'ちぇ'], ['cho', 'ちょ'],
  ['nya', 'にゃ'], ['nyu', 'にゅ'], ['nyo', 'にょ'],
  ['hya', 'ひゃ'], ['hyu', 'ひゅ'], ['hyo', 'ひょ'],
  ['mya', 'みゃ'], ['myu', 'みゅ'], ['myo', 'みょ'],
  ['rya', 'りゃ'], ['ryu', 'りゅ'], ['ryo', 'りょ'],
  ['lya', 'ゃ'], ['lyu', 'ゅ'], ['lyo', 'ょ'], ['ltu', 'っ'], ['lwa', 'ゎ'],
  ['xya', 'ゃ'], ['xyu', 'ゅ'], ['xyo', 'ょ'], ['xtu', 'っ'], ['xwa', 'ゎ'],
  # 2文字
  ['ja', 'じゃ'], ['ji', 'じ'], ['ju', 'じゅ'], ['je', 'じぇ'], ['jo', 'じょ'],
  ['fa', 'ふぁ'], ['fi', 'ふぃ'], ['fu', 'ふ'], ['fe', 'ふぇ'], ['fo', 'ふぉ'],
  ['la', 'ぁ'], ['li', 'ぃ'], ['lu', 'ぅ'], ['le', 'ぇ'], ['lo', 'ぉ'],
  ['xa', 'ぁ'], ['xi', 'ぃ'], ['xu', 'ぅ'], ['xe', 'ぇ'], ['xo', 'ぉ'],
  ['ga', 'が'], ['gi', 'ぎ'], ['gu', 'ぐ'], ['ge', 'げ'], ['go', 'ご'], ['gg', 'っg'],
  ['za', 'ざ'], ['zi', 'じ'], ['zu', 'ず'], ['ze', 'ぜ'], ['zo', 'ぞ'], ['zz', 'っz'],
  ['da', 'だ'], ['di', 'ぢ'], ['du', 'づ'], ['de', 'で'], ['do', 'ど'], ['dd', 'っd'],
  ['ba', 'ば'], ['bi', 'び'], ['bu', 'ぶ'], ['be', 'べ'], ['bo', 'ぼ'], ['bb', 'っb'],
  ['pa', 'ぱ'], ['pi', 'ぴ'], ['pu', 'ぷ'], ['pe', 'ぺ'], ['po', 'ぽ'], ['pp', 'っp'],
  ['ka', 'か'], ['ki', 'き'], ['ku', 'く'], ['ke', 'け'], ['ko', 'こ'], ['kk', 'っk'],
  ['sa', 'さ'], ['si', 'し'], ['su', 'す'], ['se', 'せ'], ['so', 'そ'], ['ss', 'っs'],
  ['ta', 'た'], ['ti', 'ち'], ['tu', 'つ'], ['te', 'て'], ['to', 'と'], ['tt', 'っt'],
  ['na', 'な'], ['ni', 'に'], ['nu', 'ぬ'], ['ne', 'ね'], ['no', 'の'],
  ['ha', 'は'], ['hi', 'ひ'], ['hu', 'ふ'], ['he', 'へ'], ['ho', 'ほ'], ['hh', 'っh'],
  ['ma', 'ま'], ['mi', 'み'], ['mu', 'む'], ['me', 'め'], ['mo', 'も'], ['mm', 'っm'],
  ['ya', 'や'], ['yi', 'ゐ'], ['yu', 'ゆ'], ['ye', 'ゑ'], ['yo', 'よ'], ['yy', 'っy'],
  ['ra', 'ら'], ['ri', 'り'], ['ru', 'る'], ['re', 'れ'], ['ro', 'ろ'], ['rr', 'っr'],
  ['wa', 'わ'], ['wo', 'を'], ['nn', 'ん'],
  ['va', 'ゔぁ'], ['vi', 'ゔぃ'], ['vu', 'ゔ'], ['ve', 'ゔぇ'], ['vo', 'ゔぉ'],
  ['zl', '→'], ['zh', '←'], ['zj', '↓'], ['zk', '↑'],
  ['z,', '・'], ['z.', '…'], ['z[', '「'], ['z]', '」'],
  # 1文字
  ['a', 'あ'], ['i', 'い'], ['u', 'う'], ['e', 'え'], ['o', 'お'],
  ['-', 'ー'], ['.', '。'], [',', '、'], ['!', '！'], ['?', '？'], ['/', '・'], ['~', '～'],
]
# {か:'k'}みたいなdict。
# 変換時に「けんさく*する」→「けんさくs」というふうに辞書を検索する時に使う
# Init()で作る
var okuri_table = {}
# }}}

# ユーティリティー {{{
const hira_table = ('ぁあぃいぅうぇえぉおかがきぎくぐけげこご' ..
  'さざしじすずせぜそぞただちぢっつづてでとど' ..
  'なにぬねのはばぱひびぴふぶぷへべぺほぼぽ' ..
  'まみむめもゃやゅゆょよらりるれろゎわゐゑをんゔー')->split('.\zs')

const kana_table = ('ァアィイゥウェエォオカガキギクグケゲコゴ' ..
  'サザシジスズセゼソゾタダチヂッツヅテデトド' ..
  'ナニヌネノハバパヒビピフブプヘベペホボポ' ..
  'マミムメモャヤュユョヨラリルレロヮワヰヱヲンヴー')->split('.\zs')

const hankaku_table = ('ｧｱｨｲｩｳｪｴｫｵｶｶﾞｷｷﾞｸｸﾞｹｹﾞｺｺﾞ' ..
  'ｻｻﾞｼｼﾞｽｽﾞｾｾﾞｿｿﾞﾀﾀﾞﾁﾁﾞｯﾂﾂﾞﾃﾃﾞﾄﾄﾞ' ..
  'ﾅﾆﾇﾈﾉﾊﾊﾞﾊﾟﾋﾋﾞﾋﾟﾌﾌﾞﾌﾟﾍﾍﾞﾍﾟﾎﾎﾞﾎﾟ' ..
  'ﾏﾐﾑﾒﾓｬﾔｭﾕｮﾖﾗﾘﾙﾚﾛﾜﾜｲｴｦﾝｳﾞｰ')->split('.[ﾟﾞ]\?\zs')

const alphabet_table = ('０１２３４５６７８９' ..
  'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ' ..
  'ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ' ..
  '！＂＃＄％＆＇（）－＾＼＠［；：］，．／＼＝～｜｀｛＋＊｝＜＞？＿')->split('.\zs')

const abbr_table = ('0123456789' ..
  'abcdefghijklmnopqrstuvwxyz' ..
  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ..
  '!"#$%&''()-^\@[;:],./\=~|`{+*}<>?_')->split('.\zs')

def ConvChars(src: string, from_chars: list<string>, to_chars: list<string>): string
  var dest = []
  for c in src->split('.\zs')
    const p = from_chars->index(c)
    dest += [p ==# - 1 ? c : to_chars[p]]
  endfor
  return dest->join('')
enddef

def SwapChars(src: string, a: list<string>, b: list<string>): string
  var dest = []
  for c in src->split('.\zs')
    const p = a->index(c)
    if p !=# -1
      dest->add(b[p])
      continue
    endif
    const q = b->index(c)
    if q !=# -1
      dest->add(a[q])
      continue
    endif
    dest->add(c)
  endfor
  return dest->join('')
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

def Uniq(list: list<any>): list<any>
  return list->filter((i, v) => list->index(v) ==# i)
enddef
# }}}

# 基本 {{{
def EscapeForMap(key: string): string
  return key
    ->substitute('<', '<LT>', 'g')
    ->substitute('|', '<Bar>', 'g')
    ->substitute(' ', '<Space>', 'g')
    ->substitute('\', '<Bslash>', 'g')
enddef

def MapForInput(key: string)
  const k = EscapeForMap(key)
  const v = key->escape('"|\\')
  execute $'lnoremap <buffer> <script> <expr> {k} I("{v}")'
enddef

def Unmap(key: string)
  const k = EscapeForMap(key)
  silent! execute $'lunmap <buffer> <script> <expr> {k}'
enddef

# <buffer>にマッピングしないと`imap <buffer>`に取られちゃう
def MapToBuf()
  for k in abbr_table + '[],.'->split('.\zs')
    const m = maparg(k, 'l', false, true)
    if !!m
      save_lmap[k] = m
    else
      MapForInput(k)
    endif
  endfor
  lnoremap <buffer> <script> <expr> <Space> OnSpace()
  lnoremap <buffer> <script> <expr> <CR> OnCR()
enddef

def Init()
  MapToBuf()
  noremap! <script> <expr> <Plug>(vim9skk-kana) ToggleMode(mode_kata)
  noremap! <script> <expr> <Plug>(vim9skk-hankaku) ToggleMode(mode_hankaku)
  noremap! <script> <expr> <Plug>(vim9skk-alphabet) ToggleMode(mode_alphabet)
  noremap! <script> <expr> <Plug>(vim9skk-abbr) ToggleAbbr()
  noremap! <script> <Plug>(vim9skk-hira) <ScriptCmd>SetMode(mode_hira)<CR>
  noremap! <script> <expr> <Plug>(vim9skk-midasi) SetMidasi()
  noremap! <script> <expr> <Plug>(vim9skk-prev) Select(-1)
  noremap! <script> <expr> <Plug>(vim9skk-next) Select(1)
  augroup vim9skk
    autocmd!
    autocmd BufEnter * MapToBuf()
    autocmd InsertEnter * OnInsertEnter()
    autocmd InsertLeave * OnInsertLeave()
    autocmd CmdlineEnter * OnCmdlineEnter()
    autocmd CmdlineLeave * CloseKouho()
    autocmd VimLeave * SaveRecentlies()
  augroup END
  for kv in roma_table
    okuri_table[kv[1]->strcharpart(0, 1)] = kv[0][0]
  endfor
  SetMode(mode_hira)
  initialized = true
enddef

def ToDirectMode(s: string = ''): string
  skkmode = skkmode_direct
  start_pos = GetPos()
  CloseKouho()
  if mode ==# mode_abbr
    SetMode(mode_hira)
  endif
  return s
enddef

export def ToggleSkk(): string
  if !initialized
    Init()
  endif
  &iminsert = &iminsert ==# 1 ? 0 : 1
  ToDirectMode()
  if mode ==# mode_abbr || mode ==# mode_alphabet
    SetMode(mode_hira)
    return ''
  else
    ShowMode(true)
    return "\<C-^>"
  endif
enddef

def SetMode(m: number)
  mode = m
  for [k, v] in save_lmap->items()
    if m ==# mode_abbr || m ==# mode_alphabet
      # `q`とか`l`とかを入力できるようにする
      MapForInput(k)
    else
      # `q`とか`l`とかのマッピングを復活
      Unmap(k)
      mapset('l', false, v)
    endif
  endfor
  if skkmode !=# skkmode_select
    CloseKouho()
  endif
  ShowMode(true)
enddef

def ShowMode(popup_even_off: bool)
  if &iminsert !=# 1
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
  if 0 < g:vim9skk.mode_label_timeout && (popup_even_off || &iminsert ==# 1)
    popup_mode_id = popup_create(g:vim9skk_mode, {
      col: mode() ==# 'c' ? 2 : 'cursor',
      line: mode() ==# 'c' ? (&lines - 1) : 'cursor+1',
      time: g:vim9skk.mode_label_timeout,
    })
  endif
  redraw
  doautocmd User Vim9skkModeChanged
enddef

def CloseModePopup()
  if !!popup_mode_id
    popup_close(popup_mode_id)
    popup_mode_id = 0
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
  if getcmdtype() =~# '[/?]'
    ShowMode(false)
  else
    CloseModePopup()
  endif
enddef
# }}}

# キー入力 {{{
def I(c: string): string
  var prefix = ''
  # 候補を選択中の場合
  if skkmode ==# skkmode_select
    if c ==# 'x'
      return Select(-1)
    endif
    prefix = Complete()
  else
    pos_delta = 0
  endif
  # 英数入力
  if mode ==# mode_abbr
    return prefix .. c
  elseif mode ==# mode_alphabet
    return prefix .. c->ConvChars(abbr_table, alphabet_table)
  endif
  # ここから先はローマ字入力の処理
  # 大文字入力で見出しを開始する
  if c =~# '[A-Z]'
    prefix ..= SetMidasi()
    start_pos += pos_delta
  endif
  # ローマ字をひらがなに変換する
  var before = ''
  var after = ''
  const key = (GetLine()->matchstr($'.\?.\%{GetPos()}c') .. c)->tolower()
  for r in roma_table
    if key[-len(r[0]) :] ==# r[0]
      before = r[0]
      after ..= r[1]
      break
    endif
  endfor
  if !after && key[-2 : -2] ==# 'n' && c !=# 'y'
    before = 'n' .. c
    after ..= 'ん' .. c
  endif
  if !after
    return prefix .. c
  endif
  if mode ==# mode_kata
    after = after->ConvChars(hira_table, kana_table)
  elseif mode ==# mode_hankaku
    after = after->ConvChars(hira_table, hankaku_table)
  endif
  if skkmode ==# skkmode_midasi
    GetTarget()
      ->substitute($'^{g:vim9skk.marker_midasi}', '', '')
      ->substitute($'^{g:vim9skk.marker_select}', '', '')
      ->substitute('.'->repeat(len(before) - 1) .. '$', '', '')
      ->AddStr(after)
      ->ShowResent()
  endif
  return "\<BS>"->repeat(len(before) - 1) .. prefix .. after
enddef

def SetMidasi(): string
  if skkmode ==# skkmode_midasi
    if GetTarget() =~# g:vim9skk.marker_midasi
      return '*'
    endif
  endif
  if skkmode ==# skkmode_select
    return ''
  endif
  skkmode = skkmode_midasi
  start_pos = GetPos()
  return '▽'
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
      ->SwapChars(hira_table, kana_table)
      ->SwapChars(alphabet_table, abbr_table)
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
  pos_delta = len(result) - len(s)
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
  const head = $'{key} '
  for j in ReadJisyo(path)
    if j->StartsWith(head)
      var result = []
      for k in j->Split(' ')[1]->split('/')
        result->add(k->substitute(';.*$', '', ''))
      endfor
      return result
    endif
  endfor
  return []
enddef

def GetAllKouho(target: string)
  if !target
    return
  endif
  # `▽ほげ*ふが`を見出しと送り仮名に分割する
  const [midasi, o] = target
    ->substitute(g:vim9skk.marker_midasi, '', '')
    ->ConvChars(kana_table, hira_table)
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
  kouho->Uniq()
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
    pos_delta -= p->matchstr('.$')->len()
    return p .. "\<Left>"
  else
    return p
  endif
enddef

def Complete(): string
  RegisterToRecentJisyo(henkan_key, kouho[kouho_index])
  return GetTarget()
    ->RemoveMarker()
    ->AddLeftForParen()
    ->ReplaceTarget()
    ->ToDirectMode()
enddef
#}}}

# 予測変換ポップアップ {{{
def ShowResent(_target: string): string
  var target = _target
  if mode ==# mode_hira || mode ==# mode_kata
    target = target->substitute('n$', 'ん', '')
  endif
  kouho = [target]
  for j in ReadJisyo(g:vim9skk.jisyo_recent)
    if j->StartsWith(target)
      kouho += j->Split(' ')[1]->split('/')
    endif
  endfor
  if len(kouho) ==# 1
    return ''
  endif
  kouho->Uniq()
  kouho_index = 0
  okuri = ''
  PopupKouho()
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
        col: screencol(),
        line: 'cursor+1',
        pos: 'topright',
    })
  )
  HighlightKouho()
enddef

def HighlightKouho()
  win_execute(popup_kouho_id, $':{kouho_index + 1}')
enddef

def CloseKouho()
  g:vim9skk_selectable = false
  if popup_kouho_id !=# 0
    popup_close(popup_kouho_id)
    popup_kouho_id = 0
  endif
enddef
#}}}

# 辞書操作 {{{
def ToFullPathAndEncode(path: string): list<string>
  const m = path->matchlist('\(.\+\):\([a-zA-Z0-9-]\+\)$')
  if !m
    return [expand(path), '']
  else
    return [expand(m[1]), m[2]]
  endif
enddef

def Iconv(lines: list<string>, from_enc: string, to_enc: string): list<string>
  const f = from_enc ?? &enc
  const t = to_enc ?? &enc
  if !lines || f ==# t
    return lines
  endif
  var result = []
  for l in lines
    result->add(l->iconv(f, t))
  endfor
  return result
enddef

def ReadJisyo(path: string): list<string>
  # キャッシュ済み
  if jisyo->has_key(path)
    return jisyo[path]
  endif
  # 読み込んでスクリプトローカルにキャッシュする
  const [p, enc] = ToFullPathAndEncode(path)
  if !filereadable(p)
    return []
  endif
  jisyo[path] = readfile(p)->Iconv(enc, &enc)
  return jisyo[path]
enddef

def WriteJisyo(lines: list<string>, path: string, flags: string = '')
  const [p, enc] = ToFullPathAndEncode(path)
  writefile(lines->Iconv(&enc, enc), p, flags)
enddef

export def RegisterToUserJisyo(key: string): list<string>
  const save_mode = mode
  const save_start_pos = start_pos
  const save_okuri = okuri
  var result = []
  try
    const value = input($'ユーザー辞書に登録({key}): ')->trim()
    if !value
      echo 'キャンセルしました'
    else
      # ユーザー辞書に登録する
      const newline = [$'{key} /{value}/']
      jisyo[g:vim9skk.jisyo_user] = get(jisyo, g:vim9skk.jisyo_user, [])
      jisyo[g:vim9skk.jisyo_user] += newline
      WriteJisyo(newline, expand(g:vim9skk.jisyo_user), 'a')
      echo '登録しました'
      result += [value]
    endif
  finally
    mode = save_mode
    start_pos = save_start_pos
    okuri = save_okuri
  endtry
  return result
enddef

def RegisterToRecentJisyo(before: string, after: string)
  var lines = get(jisyo, g:vim9skk.jisyo_recent, [])
  var afters = [after] + GetKouhoFromJisyo(g:vim9skk.jisyo_recent, before)
  afters->Uniq()
  const newline = $'{before} /{afters->join("/")}/'
  const i = lines->indexof((i, v) => v->StartsWith($'{before} '))
  if i !=# -1
    lines->remove(i)
  endif
  jisyo[g:vim9skk.jisyo_recent] = [newline] + lines[: g:vim9skk.recent]
enddef

def SaveRecentlies()
  var lines = get(jisyo, g:vim9skk.jisyo_recent, [])
  if !!lines
    WriteJisyo(lines, g:vim9skk.jisyo_recent)
  endif
enddef

export def RefreshJisyo()
  jisyo = {}
  echo '辞書をリフレッシュしました'
enddef
#}}}

