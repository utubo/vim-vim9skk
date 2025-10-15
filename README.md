# 注意
現在、こちらは開発を中断しvim9skkpを開発しています
https://github.com/utubo/vim-vim9skkp.vim

# 🧩vim9skk
vim9skk は、Vim9 Scriptで実装したSKK日本語入力プラグインです

[doc/vim9skk.txt](doc/vim9skk.txt)

~~絶賛作成中です~~  
🐞だらけだと思います！  

## 🐋Dockerでお試し
お試し用のDockerfileを用意しました  
コンテナ起動後インサートモードで `<C-j>` で日本語入力できます
```
docker build . -t vim-vim9skk
docker run --rm --name vim-vim9skk -it vim-vim9skk
```

## 🔨破壊的変更履歴

- 2025/08/05 設定名を変更しました `change_popuppos` → `getcurpos`
- 2024/11/15 モードのポップアップをカーソルに追従するようにしました
- 2024/11/15 `▽`を挿入しないようにしました
- 2023/12/12 イベントの名前を一部変更しました
- 2023/11/23 マッピングのカスタマイズ方法を大幅に変更しました
