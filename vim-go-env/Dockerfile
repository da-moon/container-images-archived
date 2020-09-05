FROM golang:alpine
COPY --from=fjolsvin/vim-builder:latest /usr/local/bin/ /usr/local/bin
COPY --from=fjolsvin/vim-builder:latest /usr/local/share/vim/ /usr/local/share/vim/
ENV USER "developer"
USER root
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk upgrade -U -a && \
  apk add --no-cache cmake py3-pip bash sudo curl ruby-dev lua lua-dev luajit luarocks python3-dev perl perl-dev build-base ctags git libx11-static libx11-dev libxpm-dev libxt-dev make ncurses-dev ncurses-static apk-tools-static
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
# => cleanups
RUN rm -rf $(go env GOPATH)/src && \
    sudo rm -rf $(go env GOPATH)/pkg && \
    rm -rf ~/.cache/go* && \
    sudo rm -rf /tmp/*
COPY vimrc /home/${USER}/.vimrc
ENTRYPOINT bash -c "sudo chown '$USER:$USER' /workspace -R && bash"
