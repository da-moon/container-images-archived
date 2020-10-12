FROM alpine:3.10 AS builder
RUN apk add --no-cache --virtual .build wget cmake make gcc g++ linux-headers zlib-dev openssl-dev git \
            automake autoconf libevent-dev ncurses-dev msgpack-c-dev libexecinfo-dev \
            ncurses-static libexecinfo-static libevent-static msgpack-c ncurses-libs \
            libevent libexecinfo openssl zlib && \
    mkdir -p /src/libssh/build /workspace && \
    git clone https://github.com/tmate-io/tmate.git /workspace/tmate
WORKDIR /src
RUN wget -O libssh.tar.xz https://www.libssh.org/files/0.9/libssh-0.9.0.tar.xz && \
    tar -xf libssh.tar.xz -C /src/libssh --strip-components=1
WORKDIR /src/libssh/build
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr \
      -DWITH_SFTP=OFF -DWITH_SERVER=OFF -DWITH_PCAP=OFF \
      -DWITH_STATIC_LIB=ON -DWITH_GSSAPI=OFF ..
RUN make -j $(nproc)
RUN make install
WORKDIR /workspace/tmate
RUN ./autogen.sh && \
    ./configure --enable-static && \
    make -j $(nproc) && \
    objcopy --only-keep-debug tmate tmate.symbols && \
    chmod -x tmate.symbols && \
    strip tmate
RUN echo "nobody:x:65534:65534:Nobody:/:" > /etc_passwd
FROM alpine
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc_passwd /etc/passwd
COPY --from=builder --chown=65534:0 /workspace/tmate/tmate.symbols /workspace/tmate.symbols
COPY --from=builder --chown=65534:0 /workspace/tmate/tmate /workspace/tmate
USER nobody
RUN /workspace/tmate -V
ENTRYPOINT ["/workspace/tmate"]
