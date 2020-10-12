# this is the base dockerfile for packaging python applications
FROM debian as pyoxidizer_builder
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV OPENSSL_LIB_DIR="/usr/lib/x86_64-linux-gnu"
ENV OPENSSL_INCLUDE_DIR="/usr/include/openssl"
ENV TERM=xterm
ENV PIP_USER=false
SHELL ["/bin/bash", "-c"]
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -yqq apt-utils pkg-config && \
    apt-get install -yqq curl gcc git make libssl-dev python3-dev python3-pip
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile minimal && \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME && \
    rustup --version && \
    cargo --version && \
    rustc --version
RUN cargo install -j$(nproc) pyoxidizer
RUN mkdir -p "/workspace" && \
    mkdir -p "~/.local/bin" && \
    mkdir -p "~/.poetry/bin" && \
    curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3 && \
    python3 -m pip install pex dephell[full] && \
    dephell --version && \
    pex --version
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get autoclean -y && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 
