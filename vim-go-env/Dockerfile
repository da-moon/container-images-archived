FROM golang:alpine
COPY --from=fjolsvin/vim-builder:latest /usr/local/bin/ /usr/local/bin
COPY --from=fjolsvin/vim-builder:latest /usr/local/share/vim/ /usr/local/share/vim/
ENV USER "developer"
USER root
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade -U -a && \
  apk add --no-cache bash sudo curl ruby-dev lua lua-dev luajit luarocks python3-dev perl perl-dev build-base ctags git libx11-static libx11-dev libxpm-dev libxt-dev make ncurses-dev ncurses-static apk-tools-static
RUN getent group sudo > /dev/null || sudo addgroup sudo
RUN getent group ${USER} > /dev/null || sudo addgroup ${USER}
RUN getent passwd ${USER} > /dev/null || sudo adduser \
    -G sudo \
    -h "/home/${USER}" \
    -s /bin/bash \
    -u 33333 \
    -D \
    "${USER}" "${USER}"
RUN rm -r /go && \
    echo "${USER}:${USER}" | chpasswd && \ 
    sed -i.bak -e "s/# %sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g" /etc/sudoers && \
    mkdir -p /workspace && \
    chown "$USER:$USER" /workspace -R 
USER ${USER}
RUN sudo echo "Running 'sudo' for ${USER} : success"
ENV GOPATH=/workspace
ENV PATH=$GOPATH/bin:$PATH
RUN mkdir -p $(go env GOPATH)/{src,bin,pkg} 
RUN go get -u -v honnef.co/go/tools/cmd/staticcheck && \
cd $(go env GOPATH)/src/honnef.co/go/tools/cmd/staticcheck && \
git checkout 2020.1.4 && \
go get && \
go install

ENV GO111MODULE on
WORKDIR $GOPATH 
## => for vscode
RUN wget -O- -nv https://raw.githubusercontent.com/alecthomas/gometalinter/master/scripts/install.sh | sudo sh -s -- -b $(go env GOPATH)/bin && \
    sudo chown "${USER}:${USER}" $(go env GOPATH) -R
RUN wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.30.0
RUN go get -u -v github.com/mdempsky/gocode
RUN go get -u -v github.com/ramya-rao-a/go-outline
RUN go get -u -v github.com/acroca/go-symbols
RUN go get -u -v golang.org/x/tools/cmd/guru
RUN go get -u -v golang.org/x/tools/cmd/gorename
RUN go get -u -v github.com/fatih/gomodifytags
RUN go get -u -v github.com/haya14busa/goplay/cmd/goplay
RUN go get -u -v github.com/josharian/impl
RUN go get -u -v github.com/tylerb/gotype-live
RUN go get -u -v github.com/rogpeppe/godef
RUN go get -u -v github.com/zmb3/gogetdoc
RUN go get -u -v golang.org/x/tools/cmd/goimports
RUN go get -u -v github.com/sqs/goreturns
RUN go get -u -v winterdrache.de/goformat/goformat
RUN go get -u -v golang.org/x/lint/golint
RUN go get -u -v github.com/cweill/gotests/...
RUN go get -u -v honnef.co/go/tools/...
RUN go get -u -v github.com/mgechev/revive
RUN go get -u -v github.com/sourcegraph/go-langserver
RUN go get -u -v github.com/go-delve/delve/cmd/dlv
RUN go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct
RUN go get -u -v github.com/godoctor/godoctor
RUN go get -u -v golang.org/x/tools/gopls
# => extra ...
RUN go get -u -v mvdan.cc/gofumpt
RUN go get -u -v github.com/cuonglm/gocmt
RUN go get -u -v github.com/palantir/go-compiles
RUN go get -u -v github.com/mohae/nocomment/cmd/nocomment
RUN go get -u -v github.com/eandre/discover/...
# => cleanups
RUN rm -rf $(go env GOPATH)/src && \
    sudo rm -rf $(go env GOPATH)/pkg && \
    rm -rf ~/.cache/go* && \
    sudo rm -rf /tmp/*
COPY vimrc /home/${USER}/.vimrc
ENTRYPOINT ["vim"]
