FROM alpine:3.14 AS builder
LABEL maintainer="ZeroMQ Project <zeromq@imatix.com>"
ARG DEBIAN_FRONTEND=noninteractive
RUN apk update \
    && apk add \
        autoconf \
        automake \
        build-essential \
        git \
        libkrb5-dev \
        libsodium-dev \
        libtool \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/libzmq
COPY . .
RUN ./autogen.sh \
    && ./configure --prefix=/usr/local --with-libsodium --with-libgssapi_krb5 \
    && make \
    && make check \
    && make install

FROM alpine:3.14
LABEL maintainer="ZeroMQ Project <zeromq@imatix.com>"
ARG DEBIAN_FRONTEND=noninteractive
RUN apk update \
    && apk add \
        libkrb5-dev \
        libsodium
COPY --from=builder /usr/local /usr/local
RUN ldconfig && ldconfig -p | grep libzmq
