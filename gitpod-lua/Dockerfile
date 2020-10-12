FROM gitpod/workspace-full
USER gitpod
SHELL ["/bin/bash", "-c"]
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
RUN sudo apt-get autoclean -y && \ 
  sudo apt-get clean && \
  sudo rm -rf /var/lib/apt/lists/* && \
  sudo rm -rf /tmp/* && \
  sudo rm -rf /home/gitpod/.cache/* && \
  sudo rm -rf /etc/bash_completion.d/rustup*
WORKDIR /home/gitpod
