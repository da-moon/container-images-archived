FROM alpine:latest
RUN apk update && \
    apk add --no-cache curl ruby-dev lua lua-dev luajit luarocks python3-dev perl perl-dev build-base ctags git libx11-static libx11-dev libxpm-dev libxt-dev make ncurses-dev ncurses-static apk-tools-static
RUN git clone https://github.com/vim/vim /tmp/vim 
#ARG LDFLAGS="-static"
#ENV LDFLAGS $LDFLAGS
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
      --enable-luainterp=yes \
      --enable-python3interp=yes \
      --enable-rubyinterp=yes \
      --enable-perlinterp=yes \
      --with-python3-config-dir=$(python3-config --configdir) \
      --with-tlib=ncursesw \
      --with-x \
      --with-features=huge 
RUN make install && \
    vim --version && \
    ldd $(which vim)
