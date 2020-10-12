FROM golang:alpine AS github-release-builder
RUN apk add --no-cache git && \
    go get -v github.com/github-release/github-release
FROM alpine:latest as rust-builder
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache curl ca-certificates gcc build-base git openssl-dev musl-dev libffi-dev && \
    mkdir /etc/bash_completion.d && \ 
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --no-modify-path \
    --default-host x86_64-unknown-linux-musl \
    --default-toolchain stable \
    --profile complete && \
    source /usr/local/cargo/env && \
    cargo install -j $(nproc) cargo-watch cargo-edit cargo-tree
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
FROM alpine:latest
ENV HOME=/home/gitpod
ENV LANG=en_US.UTF-8
COPY --from=fjolsvin/tmate-static-builder /workspace/tmate /usr/local/bin/tmate
COPY --from=rust-builder /usr/local/cargo/bin /usr/local/bin
COPY --from=rust-builder /etc/bash_completion.d/ /etc/bash_completion.d/
COPY --from=vim-builder /usr/local/bin/vim /usr/local/bin/vim
COPY --from=vim-builder /usr/local/share/vim/ /usr/local/share/vim/
COPY --from=github-release-builder /go/bin/github-release /usr/local/bin/github-release
COPY vimrc "${HOME}/.vimrc"
COPY vimrc.d "${HOME}/.vimrc.d"
WORKDIR $HOME
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache curl wget git build-base make ncurses ncurses-dev bash sudo jq bzip2 openssl-dev musl-dev libffi-dev upx python3-dev dropbear yarn nodejs htop && \
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
   { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ;} >> .bashrc && \
    chown "gitpod:gitpod" /home/gitpod -R

USER gitpod
# checking binaries copied from other stages
RUN vim --version && \
    tmate -V && \
    # chisel returns exit code 1
    chisel --version || true
# use sudo so that user does not get sudo usage info on (the first) login
RUN sudo echo "Running 'sudo' for Gitpod: success" && \
    rustup default stable && \
    rustup --version && \
    cargo --version && \
    rustc --version && \
    rustup completions bash | sudo tee /etc/bash_completion.d/rustup.bash-completion > /dev/null && \
    rustup completions bash cargo | sudo tee /etc/bash_completion.d/rustup.cargo-bash-completion > /dev/null && \
    rustup toolchain uninstall stable && \
    rustup component add rls rust-analysis rust-src
RUN (echo | vim -c "CocInstall -sync coc-tsserver \
            coc-git \
            coc-bookmark \
            coc-snippets \
            coc-highlight \
            coc-json \
            coc-lists \
            coc-markdownlint \
            coc-tabnine \
            coc-tasks \
            coc-todolist \
            coc-template \
            coc-yank \
            coc-pairs \
            coc-svg \
            coc-yaml \
            coc-spell-checker \
            coc-rls \
            coc-sh \
            coc-prettier|q" > /dev/null && \
            echo 0 ) || true
RUN timeout 5m vim || true

