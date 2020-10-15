FROM golang:alpine AS go-package-builder
# install deps
RUN apk add --no-cache git && \
    GO111MODULE=off go get -d -v gitlab.com/NebulousLabs/Sia/... && \
    GO111MODULE=off go get -d -v gitlab.com/NebulousLabs/Sia-Ant-Farm/...
RUN GO111MODULE=on go get -v github.com/nickng/dingo-hunter
RUN GO111MODULE=on go get -v github.com/kisielk/errcheck
RUN GO111MODULE=on go get -v gitlab.com/opennota/check/cmd/aligncheck
RUN GO111MODULE=on go get -v gitlab.com/opennota/check/cmd/structcheck
RUN GO111MODULE=on go get -v gitlab.com/opennota/check/cmd/varcheck
RUN GO111MODULE=on go get -v github.com/go-critic/go-critic/cmd/gocritic
RUN GO111MODULE=on go get -v golang.org/x/tools/cmd/...
RUN GO111MODULE=on go get -v github.com/mdempsky/unconvert
RUN GO111MODULE=on go get -v github.com/psampaz/go-mod-outdated
RUN GO111MODULE=on go get -v github.com/palantir/outparamcheck
RUN GO111MODULE=off go get -v github.com/alexkohler/prealloc/...
RUN GO111MODULE=off go get -v github.com/alexkohler/unimport/...
RUN GO111MODULE=off go get -v github.com/alexkohler/nakedret/...
RUN GO111MODULE=off go get -v github.com/gordonklaus/ineffassign/...
RUN GO111MODULE=off go get -v github.com/sqs/goreturns/...
RUN GO111MODULE=off go get -v github.com/client9/misspell/cmd/misspell
RUN GO111MODULE=off go get -v github.com/alexkohler/nargs/cmd/nargs
RUN GO111MODULE=off go get -v github.com/alexkohler/dogsled/cmd/dogsled
RUN GO111MODULE=off go get -v github.com/alexkohler/identypo/cmd/identypo
RUN GO111MODULE=off go get -v github.com/mibk/dupl/...
RUN GO111MODULE=off go get -v mvdan.cc/interfacer/...
RUN GO111MODULE=off go get -v github.com/ttarvis/glasgo/...
WORKDIR $GOPATH/src/gitlab.com/NebulousLabs/Sia
RUN GO111MODULE=on go build -o "$GOPATH/bin/siac" -tags='debug,dev' gitlab.com/NebulousLabs/Sia/cmd/siac && \
    GO111MODULE=on go build -o "$GOPATH/bin/siad" -tags='debug,dev' gitlab.com/NebulousLabs/Sia/cmd/siad
WORKDIR $GOPATH/src/gitlab.com/NebulousLabs/Sia-Ant-Farm
RUN GO111MODULE=on go build -o "$GOPATH/bin/sia-antfarm" -tags='debug,dev' gitlab.com/NebulousLabs/Sia-Ant-Farm/cmd/sia-antfarm
FROM fjolsvin/gitpod-go
USER root
COPY --from=go-package-builder /go/bin/ /usr/local/bin/
COPY --from=go-package-builder /go/bin/siac /usr/local/bin/siac-dev
COPY --from=go-package-builder /go/bin/siad /usr/local/bin/siad-dev
ENV HASHICORP_BASE_URL="https://releases.hashicorp.com"
RUN siad version && \
    sia-antfarm --help && \
    siac version || true
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk upgrade --no-cache && \
    apk add --no-cache words asciinema cfssl chromium ansible && \
    yarn global add puppeteer  && \
    yarn global add carbon-now-cli --prefix /usr/local && \
    yarn global add typescript --prefix /usr/local && \
    yarn global add @mermaid-js/mermaid-cli --prefix /usr/local && \
    mkdir -p "/etc/mmdc/" && \
    jq -n --arg arg_one "--no-sandbox" '{"args":[$arg_one]}' > /etc/mmdc/puppeteer-config.json
RUN curl -L https://getenvoy.io/cli | \
    bash -s -- -b /usr/local/bin && \
    getenvoy --version
RUN curl -sL "$HASHICORP_BASE_URL/vault/index.json" | \ 
    jq -r '.versions[].version' | \
    sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
    grep -E -v 'ent|rc|beta' | \
    tail -1 | \
    xargs -I {} \
    wget -q -O /usr/local/bin/vault.zip "$HASHICORP_BASE_URL/vault/{}/vault_{}_linux_amd64.zip" && \
    unzip -q -d /usr/local/bin /usr/local/bin/vault.zip && \
    rm /usr/local/bin/vault.zip && \
    vault --version
RUN curl -sL "$HASHICORP_BASE_URL/consul/index.json" | \ 
    jq -r '.versions[].version' | \
    sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | \
    grep -E -v 'ent|rc|beta' | \
    tail -1 | \
    xargs -I {} \
    wget -q -O /usr/local/bin/consul.zip "$HASHICORP_BASE_URL/consul/{}/consul_{}_linux_amd64.zip" && \
    unzip -q -d /usr/local/bin /usr/local/bin/consul.zip && \
    rm /usr/local/bin/consul.zip && \
    consul --version
RUN curl -sL https://api.github.com/repos/prometheus/prometheus/releases/latest | \
    jq -r '.assets[] | select(.name | contains("linux") and contains("amd64")).browser_download_url' | \
    xargs -I {} \
    wget -q -O /tmp/prometheus.tar.gz {} && \ 
    tar -C /tmp -xvzf /tmp/prometheus.tar.gz && \
    mkdir -p /etc/prometheus /var/lib/prometheus && \
    mv /tmp/prometheus*/prometheus /usr/local/bin/prometheus && \
    mv /tmp/prometheus*/promtool /usr/local/bin/promtool && \
    rm -r /tmp/prometheus* && \
    prometheus --version && \
    promtool --version  
RUN curl -sL https://api.github.com/repos/traefik/traefik/releases/latest | \
    jq -r '.assets[] | select(.name | contains("linux") and contains("amd64")).browser_download_url' | \
    xargs -I {} \
    wget -q -O /tmp/traefik.tar.gz {} && \ 
    mkdir /tmp/traefik && \
    tar -C /tmp/traefik -xvzf /tmp/traefik.tar.gz && \
    mv /tmp/traefik/traefik /usr/local/bin/traefik && \
    rm -r /tmp/traefik.tar.gz && \
    traefik version  
RUN curl -sL https://api.github.com/repos/stripe/stripe-cli/releases/latest | \
    jq -r '.assets[] | select(.name | contains("linux") and contains("x86_64") and contains("tar")).browser_download_url'| \
    xargs -I {} \
    wget -q -O /tmp/stripe.tar.gz {} && \ 
    tar -C /usr/local/bin -xvzf /tmp/stripe.tar.gz && \
    rm -r /tmp/stripe.tar.gz && \
    stripe --version  
USER gitpod
ENV CHROME_BIN=/usr/bin/chromium-browser 
ENV CHROME_PATH=/usr/lib/chromium/
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD 1
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser
ENV STRIPE_DEVICE_NAME=gitpod
RUN mkdir -p ~/.aws && \
    python3 -m pip install --upgrade awscli && \
    echo "alias mmdc='mmdc -p /etc/mmdc/puppeteer-config.json'" >> ~/.bashrc && \
    echo 'export PATH="$PATH:/go/src/github.com/bifrostcloud/bifrost/bin"' >>~/.bashrc && \
    echo 'export PATH="$PATH:/go/src/github.com/bifrostcloud/bifrost/contrib/scripts"' >>~/.bashrc && \
    echo 'export GOPRIVATE="github.com/da-moon"' >>~/.bashrc
RUN aws --version && \
    go version

