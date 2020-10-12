FROM alpine:latest
apk add --no-cache --virtual .build-deps \
		gnupg \
		tar \
		xz \
    		bzip2-dev \
		coreutils \
		dpkg-dev dpkg \
		expat-dev \
	  findutils \
		gcc \
		gdbm-dev \
		libc-dev \
		libffi-dev \
		libnsl-dev \
		libtirpc-dev \
		linux-headers \
		make \
		ncurses-dev \
		openssl-dev \
		pax-utils \
		readline-dev \
		sqlite-dev \
		tcl-dev \
		tk \
		tk-dev \
		util-linux-dev \
		xz-dev \
		zlib-dev

#ARG LDFLAGS="-static"
#ENV LDFLAGS $LDFLAGS
ARG MAKEFLAGS="-j$(nproc)"
ENV MAKEFLAGS $MAKEFLAGS
ARG CFLAGS=""
ENV CFLAGS $CFLAGS

ARG WORKING_DIR="/code/static-python"
ENV WORKING_DIR $WORKING_DIR
ARG MUSL_PREFIX="/code/static-python/musl"
ENV MUSL_PREFIX $MUSL_PREFIX
ARG PY_PREFIX="/code/static-python/python"
ENV PY_PREFIX $PY_PREFIX

# https://gist.github.com/maddouri/c4b97474f21fabc9ef61
# https://github.com/docker-library/python/blob/master/3.9/alpine3.12/Dockerfile
# https://github.com/python/cpython
