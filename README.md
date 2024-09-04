# 🧩vim9skk
vim9skk は、Vim9 Scriptで実装したSKK日本語入力プラグインです

[doc/vim9skk.txt](doc/vim9skk.txt)

絶賛作成中です  
🐞だらけだと思います！  
当面、破壊的変更がしょっちゅう入ります(特に設定まわり)

## 🐋Dockerでお試し
お試し用のDockerfileを用意しました  
コンテナ起動後インサートモードで `<C-j>` で日本語入力できます
```
docker build . -t vim-vim9skk
docker run run -it vim-vim9skk
```

## 🔨破壊的変更履歴

- 2023/12/12 イベントの名前を一部変更しました
- 2023/11/23 マッピングのカスタマイズ方法を大幅に変更しました
