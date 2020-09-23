FROM golang:alpine
COPY --from=fjolsvin/vim-builder:latest /usr/local/bin/ /usr/local/bin
COPY --from=fjolsvin/vim-builder:latest /usr/local/share/vim/ /usr/local/share/vim/
ENV USER "developer"
USER root
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade -U -a
RUN apk add ncurses 
RUN apk add cmake 
RUN apk add py3-pip
RUN apk add bash 
RUN apk add sudo 
RUN apk add curl 
RUN apk add ruby-dev
RUN apk add lua
RUN apk add lua-dev 
RUN apk add luajit 
RUN apk add luarocks 
RUN apk add python3-dev 
RUN apk add perl 
RUN apk add perl-dev 
RUN apk add build-base 
RUN apk add ctags 
RUN apk add git 
RUN apk add libx11-static 
RUN apk add libx11-dev 
RUN apk add libxpm-dev 
RUN apk add libxt-dev 
RUN apk add make 
RUN apk add ncurses-dev 
RUN apk add ncurses-static 
RUN apk add apk-tools-static 
RUN apk add nodejs 
RUN apk add yarn
RUN getent group sudo > /dev/null || sudo addgroup sudo
RUN getent group ${USER} > /dev/null || sudo addgroup ${USER}
RUN getent passwd ${USER} > /dev/null || sudo adduser \
    -G sudo \
    -h "/home/${USER}" \
    -s /bin/bash \
    -u 33333 \
    -D \
    "${USER}" "${USER}"
COPY vimrc /home/${USER}/.vimrc
COPY vimrc.d /home/${USER}/.vimrc.d
RUN rm -r /go && \
    echo "${USER}:${USER}" | chpasswd && \ 
    sed -i.bak -e "s/# %sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g" /etc/sudoers && \
    mkdir -p /workspace && \
    chown "$USER:$USER" /workspace -R && \
    chown "$USER:$USER" /home/${USER}/ -R 
USER ${USER}
RUN sudo echo "Running 'sudo' for ${USER} : success" && \
    echo 'export PATH=$PATH:~/.local/bin/'
ENV GOPATH=/workspace
ENV PATH=$GOPATH/bin:$PATH
RUN mkdir -p $(go env GOPATH)/src && \
    mkdir -p $(go env GOPATH)/bin && \
    mkdir -p $(go env GOPATH)/pkg 
RUN go get -v honnef.co/go/tools/cmd/staticcheck && \
    cd $(go env GOPATH)/src/honnef.co/go/tools/cmd/staticcheck && \
    git checkout 2020.1.4 && \
    go get && \
    go install
ENV GO111MODULE on
WORKDIR $GOPATH 
RUN go get -v mvdan.cc/gofumpt
RUN go get -v github.com/cuonglm/gocmt
RUN go get -v github.com/palantir/go-compiles
RUN go get -v github.com/mohae/nocomment/cmd/nocomment
RUN go get -v github.com/eandre/discover/...
RUN (echo | vim +PlugInstall +qall > /dev/null && echo 0) || true 
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
            coc-go \
            coc-sh \
            coc-prettier|q" > /dev/null && \
            echo 0 ) || true
# => cleanups
RUN rm -rf $(go env GOPATH)/src && \
    sudo rm -rf $(go env GOPATH)/pkg && \
    rm -rf ~/.cache/go* && \
    sudo rm -rf /tmp/*
ENTRYPOINT bash -c "sudo chown '$USER:$USER' /workspace -R && bash"
