
FROM golang:alpine AS go-pkg-builder
ARG STATIC_CHECK="2020.1.6"
ENV STATIC_CHECK $STATIC_CHECK
RUN apk add --no-cache git && \
    GO111MODULE=on go get -u -v mvdan.cc/gofumpt && \
    GO111MODULE=on go get -u -v golang.org/x/tools/gopls && \
    GO111MODULE=off go get -u -v github.com/github-release/github-release && \
    GO111MODULE=off go get -u -v github.com/mdempsky/gocode && \
    GO111MODULE=off go get -u -v github.com/uudashr/gopkgs/cmd/gopkgs && \
    GO111MODULE=off go get -u -v github.com/ramya-rao-a/go-outline && \
    GO111MODULE=off go get -u -v github.com/acroca/go-symbols && \
    GO111MODULE=off go get -u -v golang.org/x/tools/cmd/guru && \
    GO111MODULE=off go get -u -v golang.org/x/tools/cmd/gorename && \
    GO111MODULE=off go get -u -v github.com/fatih/gomodifytags && \
    GO111MODULE=off go get -u -v github.com/haya14busa/goplay/cmd/goplay && \
    GO111MODULE=off go get -u -v github.com/josharian/impl && \
    GO111MODULE=off go get -u -v github.com/tylerb/gotype-live && \
    GO111MODULE=off go get -u -v github.com/rogpeppe/godef && \
    GO111MODULE=off go get -u -v github.com/zmb3/gogetdoc && \
    GO111MODULE=off go get -u -v golang.org/x/tools/cmd/goimports && \
    GO111MODULE=off go get -u -v github.com/sqs/goreturns && \
    GO111MODULE=off go get -u -v winterdrache.de/goformat/goformat && \
    GO111MODULE=off go get -u -v golang.org/x/lint/golint && \
    GO111MODULE=off go get -u -v github.com/cweill/gotests/... && \
    GO111MODULE=off go get -u -v github.com/alecthomas/gometalinter && \
    GO111MODULE=off go get -u -v honnef.co/go/tools/... && \
    GO111MODULE=off go get -u -v github.com/mgechev/revive && \
    GO111MODULE=off go get -u -v github.com/sourcegraph/go-langserver && \
    GO111MODULE=off go get -u -v github.com/go-delve/delve/cmd/dlv && \
    GO111MODULE=off go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct && \
    GO111MODULE=off go get -u -v github.com/godoctor/godoctor && \
    GO111MODULE=off go get -u -v github.com/cuonglm/gocmt && \
    GO111MODULE=off go get -u -v github.com/palantir/go-compiles && \
    GO111MODULE=off go get -u -v github.com/mohae/nocomment/cmd/nocomment && \
    GO111MODULE=off go get -u -v github.com/eandre/discover/...  && \
    GO111MODULE=off go get -u -v honnef.co/go/tools/cmd/staticcheck && \
    cd $GOPATH/src/honnef.co/go/tools/cmd/staticcheck && \
    git checkout "$STATIC_CHECK" && \
    go get && \
    go install && \
    go get -u -v -d github.com/stamblerre/gocode && \
    go build -o $GOPATH/bin/gocode-gomod github.com/stamblerre/gocode
FROM alpine:latest as vim-builder
ENV MAKEFLAGS="-j$(nproc)"
RUN apk update && \
    apk add --no-cache curl python3-dev build-base ctags git make ncurses-dev ncurses-static apk-tools-static
RUN git clone https://github.com/vim/vim /tmp/vim 
ARG MAKEFLAGS="-j$(nproc)"
ENV MAKEFLAGS $MAKEFLAGS
ARG CFLAGS=""
ENV CFLAGS $CFLAGS
WORKDIR /tmp/vim
RUN ./configure \
      --prefix=/usr/local \
      --with-compiledby=da-moon \
      --with-modified-by=da-moon \
      --enable-fail-if-missing \
      --enable-fontset \
      --enable-cscope \
      --enable-terminal \
      --enable-multibyte \
      --enable-largefile \
      --enable-python3interp=yes \
      --with-python3-config-dir=$(python3-config --configdir) \
      --with-tlib=ncursesw \
      --with-features=huge && \
      make install
FROM golang:alpine
ENV HOME=/home/gitpod
ENV LANG=en_US.UTF-8
COPY --from=fjolsvin/tmate-static-builder /workspace/tmate /usr/local/bin/tmate
COPY --from=vim-builder /usr/local/bin/vim /usr/local/bin/vim
COPY --from=vim-builder /usr/local/share/vim/ /usr/local/share/vim/
COPY --from=go-pkg-builder /go/bin/ /usr/local/bin/
COPY vimrc "${HOME}/.vimrc"
COPY vimrc.d "${HOME}/.vimrc.d"
WORKDIR $HOME
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache --upgrade ca-certificates curl wget git build-base make ncurses ncurses-dev bash sudo jq bzip2 openssl-dev musl-dev libffi-dev upx python3-dev dropbear yarn nodejs htop py3-pip coreutils findutils grep && \
    # Install Chisel
    curl https://i.jpillora.com/chisel! | bash

SHELL ["bash", "-c"]
RUN getent group sudo > /dev/null || sudo addgroup sudo
RUN getent group gitpod > /dev/null || sudo addgroup gitpod
RUN getent passwd gitpod > /dev/null || sudo adduser \
    -G sudo \
    -h "/home/gitpod" \
    -s /bin/bash \
    -u 33333 \
    -D \
    "gitpod" "gitpod" && \
    echo "gitpod:gitpod" | chpasswd && \ 
    sed -i \
    -e '/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/d' \
    -e '/%sudo.*NOPASSWD:ALL/d' \
    /etc/sudoers && \
    echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers && \
    echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
# custom Bash prompt
   { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" && echo 'export GOPATH="/go"' && echo 'export GOROOT="/usr/local/go"' && echo 'export PATH="$PATH:$GOROOT/bin:$GOPATH/bin:~/.local/bin"';} >> .bashrc && \
    chown "gitpod:gitpod" /home/gitpod -R

USER gitpod
ENV GOPATH="/go"
ENV GOROOT="/usr/local/go"
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin:~/.local/bin

# checking binaries copied from other stages
RUN vim --version && \
    tmate -V && \
    # chisel returns exit code 1
    chisel --version || true
RUN (echo | vim -c "CocInstall -sync coc-tsserver|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-git|q"  && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-bookmark|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-snippets|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-json|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-lists|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-markdownlint|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-tabnine|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-tasks|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-todolist|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-template|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-yank|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-pairs|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-svg|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-yaml|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-spell-checker|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-go|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-sh|q" > /dev/null && echo 0 ) || true && \
    (echo | vim -c "CocInstall -sync coc-prettier|q" > /dev/null && echo 0 ) || true
