FROM thinca/vim:latest

ENV REPOS utubo/vim-vim9skk
ENV BRANCH main

RUN apk update && \
    apk --no-cache add \
    git \
    curl

ENV USER user
ENV HOME /home/$USER
RUN addgroup -S $USER && \
    adduser -S -u 1000 -G $USER $USER && \
    chown -R $USER:$USER $HOME
USER $USER
WORKDIR $HOME

ADD https://api.github.com/repos/$REPOS/git/refs/heads/$BRANCH version.json
RUN mkdir -p ~/.vim/pack/foo/start && \
    cd ~/.vim/pack/foo/start && \
    git clone https://github.com/$REPOS.git

# ↑ここまでプラグインをdockerで試すテンプレ

# SKKの辞書をダウンロードする
RUN wget http://openlab.jp/skk/dic/SKK-JISYO.L.gz && \
    gunzip -f SKK-JISYO.L.gz

