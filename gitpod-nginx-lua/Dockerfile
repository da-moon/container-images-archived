FROM fjolsvin/gitpod-lua 
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
USER root
WORKDIR /tmp
SHELL ["/bin/bash", "-c"]
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
#setting up PATH and other env vars
RUN export DEBIAN_FRONTEND=noninteractive; \
    rm -rf "/home/gitpod/.poetry" && \
    rm -rf "/home/gitpod/.local" && \
    mkdir -p "/home/gitpod/.local/bin" && \
    echo 'export PATH="$PATH:/home/gitpod/.poetry/bin"' >> "/home/gitpod/.bashrc" && \
    echo 'alias poetry="python3 /home/gitpod/.poetry/bin/poetry"' >> "/home/gitpod/.bash_aliases" 

ENV PATH="$PATH:/home/gitpod/.local/bin:/home/gitpod/.poetry/bin"
# installing poetry. poetry is a python dependancy management software
RUN export DEBIAN_FRONTEND=noninteractive; \
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python && \
    python3 "/home/gitpod/.poetry/bin/poetry" --version
# installing updating pip and installing pip packages 
RUN export DEBIAN_FRONTEND=noninteractive; \
    pip3 install dephell[full] && \
    dephell --version

#clean up
RUN export DEBIAN_FRONTEND=noninteractive; \
  apt-get autoclean -y && \ 
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*
USER gitpod

