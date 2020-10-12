FROM gitpod/workspace-full
USER gitpod
ENV PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive
ENV LUA_VERSION=5.3.5
ENV LUA_ROCKS_VERSION=3.3.1
ENV LUA_JIT_VERSION=2.0.5
# uninstalling cargo since it takes too much space
RUN yes | /home/gitpod/.cargo/bin/rustup self uninstall && \
    sudo rm /home/gitpod/.bashrc.d/80-rust
# building and installing lua
RUN yes | sudo apt update && \
    sudo apt upgrade -y && \
    sudo apt install build-essential libreadline-dev curl -y
WORKDIR /tmp
# installing lua
RUN curl -R -O "http://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz" && \
  tar -C /tmp -zxf "/tmp/lua-${LUA_VERSION}.tar.gz" && \
  cd "/tmp/lua-${LUA_VERSION}" && \
  make linux test && \
  sudo make install && \
  lua -v
WORKDIR /tmp
# installing luarocks
RUN wget "https://luarocks.org/releases/luarocks-${LUA_ROCKS_VERSION}.tar.gz" && \
  tar -C /tmp -zxf "/tmp/luarocks-${LUA_ROCKS_VERSION}.tar.gz" && \
  cd "/tmp/luarocks-${LUA_ROCKS_VERSION}" && \
  ./configure --with-lua-include=/usr/local/include && \
  make && \
  sudo make install && \
  luarocks --version
WORKDIR /tmp
# installing luajit 
RUN wget "https://luajit.org/download/LuaJIT-${LUA_JIT_VERSION}.tar.gz" && \
  tar -C /tmp -zxf "/tmp/LuaJIT-${LUA_JIT_VERSION}.tar.gz" && \
  cd "/tmp/LuaJIT-${LUA_JIT_VERSION}" && \
  make && \
  sudo make install && \
  luajit -v
# Cleaning up
USER root
WORKDIR /tmp
SHELL ["/bin/bash", "-c"]
ENV PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
RUN apt-get update && yes | apt-get install -y \
  apt-utils \ 
  build-essential \
  curl \
  jq \
  wget \
  make \
  ufw \
  perl \
  libperl-dev \
  libgd3 \
  libgd-dev \
  libgeoip1 \
  libgeoip-dev \
  geoip-bin \
  libxml2 \
  libxml2-dev \
  libxslt1.1 \
  libxslt-dev
RUN curl \
  -sL https://api.github.com/repos/cubicdaiya/nginx-build/releases/latest | \
  jq -r '.assets[] | select(.name | contains("linux")).browser_download_url' | \
  xargs -I {} wget -q --show-progress -O /tmp/nginx-build.tar.gz {}

RUN mkdir -p \
    /usr/lib/nginx/modules \
    /tmp/nginx \
    /etc/nginx/conf.d \
    /usr/lib/systemd/system \
    /var/log/nginx 

RUN export DEBIAN_FRONTEND=noninteractive; \
  tar -C /tmp/nginx -xvzf /tmp/nginx-build.tar.gz && \
  /tmp/nginx/nginx-build  -openresty \
  -d /tmp/nginx \
  -sbin-path=/sbin/nginx \
  -conf-path=/etc/nginx/nginx.conf \
  -error-log-path=/var/log/nginx/error.log \
  -pid-path=/var/run/nginx.pid \
  -lock-path=/var/lock/nginx.lock \
  -http-log-path=/var/log/nginx/access.log \
  -http-client-body-temp-path=/var/lib/nginx/body \
  -http-proxy-temp-path=/var/lib/nginx/proxy \
  -http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  -verbose \
  -idempotent \
  -openssl \
  -zlib \
  -pcre \
  -with-http_geoip_module \
  -with-http_perl_module \
  -with-http_xslt_module \
  -with-http_image_filter_module \
  -with-stream_geoip_module \
  -with-http_addition_module \
  -with-http_auth_request_module \
  -with-http_dav_module \
  -with-http_degradation_module \
  -with-http_flv_module \
  -with-http_gunzip_module \
  -with-http_gzip_static_module \
  -with-http_mp4_module \
  -with-http_random_index_module \
  -with-http_realip_module \
  -with-http_secure_link_module \
  -with-http_slice_module \
  -with-http_ssl_module \
  -with-http_stub_status_module \
  -with-http_sub_module \
  -with-http_v2_module \
  -with-poll_module \
  -with-select_module \
  -with-stream_realip_module \
  -with-stream_ssl_module \
  -with-mail_ssl_module \
  -with-stream_ssl_preread_module

RUN rm -f /tmp/nginx/openresty/*/*.tar.gz && \
  cd /tmp/nginx/openresty/*/openresty* && \
  make install && \
  make clean
RUN ln -sf /usr/lib/nginx/modules /etc/nginx/modules
#clean up
RUN export DEBIAN_FRONTEND=noninteractive; \
  apt-get autoclean -y && \ 
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*
USER gitpod

