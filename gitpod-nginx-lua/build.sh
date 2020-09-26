#!/usr/bin/env bash
# => https://www.howtoforge.com/tutorial/how-to-build-nginx-from-source-on-ubuntu-1804-lts/
set -o errtrace
set -o functrace
set -o errexit
set -o nounset
set -o pipefail
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
sudo apt update && sudo apt-get install -y build-essential curl jq wget make ufw perl libperl-dev libgd3 libgd-dev libgeoip1 libgeoip-dev geoip-bin libxml2 libxml2-dev libxslt1.1 libxslt1-dev libgoogle-perftools-dev

curl -sL https://api.github.com/repos/cubicdaiya/nginx-build/releases/latest | jq -r '.assets[] | select(.name | contains("linux")).browser_download_url' | xargs -I {} wget -q --show-progress -O /tmp/nginx-build.tar.gz {}
mkdir -p ~/.vim/
sudo rm -rf /etc/nginx/modules
sudo mkdir -p /usr/lib/nginx/modules /opt/nginx /etc/nginx/conf.d /usr/lib/systemd/system /var/log/nginx /root/.vim/
sudo chown "$USER:$USER" /opt/nginx 
tar -C /opt/nginx -xvzf /tmp/nginx-build.tar.gz
rm /tmp/nginx-build.tar.gz
#/opt/nginx/nginx-build  -openresty \
#			-d /opt/nginx \
#                        -sbin-path=/sbin/nginx \
#                        -conf-path=/etc/nginx/nginx.conf \
#                        -error-log-path=/var/log/nginx/error.log \
#                        -pid-path=/var/run/nginx.pid \
#                        -lock-path=/var/lock/nginx.lock \
#                        -http-log-path=/var/log/nginx/access.log \
#                        -http-client-body-temp-path=/var/lib/nginx/body \
#                        -http-proxy-temp-path=/var/lib/nginx/proxy \
#                        -http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
#                        -verbose \
#                        -idempotent \
#                        -openssl \
#                        -zlib \
#                        -pcre \
#                        -with-http_geoip_module=dynamic \
#                        -with-http_perl_module=dynamic \
#                        -with-http_xslt_module=dynamic \
#                        -with-http_image_filter_module=dynamic \
#                        -with-stream_geoip_module=dynamic \
#                        -with-google_perftools_module \
#                        -with-http_addition_module \
#                        -with-http_auth_request_module \
#                        -with-http_dav_module \
#                        -with-http_degradation_module \
#                        -with-http_flv_module \
#                        -with-http_gunzip_module \
#                        -with-http_gzip_static_module \
#                        -with-http_mp4_module \
#                        -with-http_random_index_module \
#                        -with-http_realip_module \
#                        -with-http_secure_link_module \
#                        -with-http_slice_module \
#                        -with-http_ssl_module \
#                        -with-http_stub_status_module \
#                        -with-http_sub_module \
#                        -with-http_v2_module \
#                        -with-poll_module \
#                        -with-select_module \
#                        -with-stream_realip_module \
#                        -with-stream_ssl_module \
#                        -with-mail_ssl_module \
#                        -with-stream_ssl_preread_module
rm -f /opt/nginx/openresty/*/*.tar.gz
pushd /opt/nginx/openresty/*/openresty*
sudo make install
#cp -rf contrib/vim/* ~/.vim/
#sudo cp -r contrib/vim/* /root/.vim/
popd
sudo rm -rf /opt/nginx
sudo ln -sf /usr/lib/nginx/modules /etc/nginx/modules

cat << EOF | sudo tee /etc/ufw/applications.d/nginx
[Nginx HTTP]
title=Web Server (Nginx, HTTP)
description=Small, but very powerful and efficient web server
ports=80/tcp

[Nginx HTTPS]
title=Web Server (Nginx, HTTPS)
description=Small, but very powerful and efficient web server
ports=443/tcp

[Nginx Full]
title=Web Server (Nginx, HTTP + HTTPS)
description=Small, but very powerful and efficient web server
ports=80,443/tcp
EOF
sudo ufw default deny 
sudo ufw default allow outgoing 
sudo ufw allow 22/tcp 
sudo ufw allow 53 
sudo ufw allow 80/tcp 
sudo ufw allow 443/tcp 
sudo ufw --force enable 
sudo ufw status numbered

cat << EOF | sudo tee /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';
    log_format verbose_log_format '[\$time_local] \$remote_addr - \$remote_user - "\$http_referer" - "\$http_user_agent" - \$server_name \$host to: \$upstream_addr: \$request \$status upstream_response_time \$upstream_response_time msec \$msec request_time \$request_time';
    access_log  /var/log/nginx/access.log  main;
    sendfile        on;
    keepalive_timeout  65;
    include /etc/nginx/conf.d/*.conf;
}
EOF
cat << EOF | sudo tee /usr/lib/systemd/system/nginx.service
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStart=/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID

[Install]
WantedBy=multi-user.target
EOF
cat << EOF | sudo tee /etc/logrotate.d/nginx
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 640 nginx adm
    sharedscripts
    postrotate
            if [ -f /var/run/nginx.pid ]; then
                    kill -USR1 \`cat /var/run/nginx.pid\`
            fi
    endscript
}
EOF
sudo adduser --system --home /nonexistent --shell /bin/false --no-create-home --disabled-login --disabled-password --gecos "nginx user" --group nginx || true

sudo chmod 640 /var/log/nginx/ -R
sudo systemctl daemon-reload
sudo systemctl enable --now nginx
sudo systemctl is-active nginx
sudo nginx -V
sudo nginx -t

