FROM gitpod/workspace-full
USER gitpod
SHELL ["/bin/bash", "-c"]
ENV PIP_USER=false
# uninstalling cargo since it takes too much space
RUN yes | /home/gitpod/.cargo/bin/rustup self uninstall && \
    sudo rm /home/gitpod/.bashrc.d/80-rust
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
  sudo apt-get autoclean -y && \ 
  sudo apt-get clean && \
  sudo rm -rf /var/lib/apt/lists/* && \
  sudo rm -rf /tmp/* && \
  sudo rm -rf /home/gitpod/.cache/* && \
  sudo rm -rf /etc/bash_completion.d/rustup*
USER gitpod

