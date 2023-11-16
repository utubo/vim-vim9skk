# vim9skk
vim9skk は、Vim9 Scriptで実装したSKK日本語入力プラグインです

[doc/vim9skk.txt](doc/vim9skk.txt)

絶賛作成中です  
WindowsのGvimで試したらフリーズしました！  
現状、辞書ファイルの文字コードの変換に時間がかかっているようなので  
SKK-JISYO.Lをあらかじめvimの内部エンコードにしなおしてSKK-JISYO.L.utf8などで保存し、
.vimrcで
```vimscript
g:vim9skk.jisyo = ['~/SKK-JISYO.L.utf8']
```
としてください

