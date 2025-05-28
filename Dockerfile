FROM alpine:3.14 AS builder
LABEL maintainer="ZeroMQ Project <zeromq@imatix.com>"
ARG DEBIAN_FRONTEND=noninteractive

ENV CFLAGS="-O2 -Wno-error"
ENV CXXFLAGS="-O2 -Wno-error"

RUN apk update && apk add --no-cache \
    autoconf \
    automake \
    git \
    krb5-dev \
    libsodium-dev \
    libtool \
    pkgconfig
    
RUN apk add --no-cache \
       git python3 npm make g++ linux-headers curl pkgconfig openssl-dev jq \
       build-base musl-dev
    
WORKDIR /opt/libzmq
COPY . .
RUN ./autogen.sh

RUN ./configure CFLAGS="-O2 -Wno-error" CXXFLAGS="-O2 -Wno-error" --prefix=/usr/local --with-libsodium --with-libgssapi_krb5

RUN make

RUN make check

RUN make install

FROM alpine:3.14
LABEL maintainer="ZeroMQ Project <zeromq@imatix.com>"
ARG DEBIAN_FRONTEND=noninteractive

RUN apk update && apk add --no-cache \
    krb5-libs \
    libsodium

COPY --from=builder /usr/local /usr/local

