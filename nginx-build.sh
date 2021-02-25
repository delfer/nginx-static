#!/bin/bash

set -e

DEBIAN_FRONTEND=noninteractive sudo apt install -y build-essential

# Bugfix https://bugs.launchpad.net/ubuntu/+source/gcc-4.4/+bug/64073
GOBK="$(pwd)"
cd /usr/lib/gcc/x86_64-linux-gnu/9/
test -f crtbeginT.orig.o ||  sudo cp crtbeginT.o crtbeginT.orig.o
sudo cp crtbeginS.o crtbeginT.o
cd $GOBK

test -f pcre-8.44.tar.gz || wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
test -d pcre-8.44 || tar -zxf pcre-8.44.tar.gz
cd pcre-8.44
./configure
make
sudo make install

cd ..

#zlib – Supports header compression. Required by the NGINX Gzip module.
test -f zlib-1.2.11.tar.gz || wget http://zlib.net/zlib-1.2.11.tar.gz
test -d zlib-1.2.11 ||  tar -zxf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure
make
sudo make install

cd ..

#OpenSSL – Supports the HTTPS protocol. Required by the NGINX SSL module and others.
test -f openssl-1.1.1g.tar.gz || wget http://www.openssl.org/source/openssl-1.1.1g.tar.gz
test -d openssl-1.1.1g || tar -zxf openssl-1.1.1g.tar.gz
cd openssl-1.1.1g
./config --prefix=/usr
make
sudo make install

cd ..

test -f nginx-1.19.7.tar.gz || wget https://nginx.org/download/nginx-1.19.7.tar.gz
test -d nginx-1.19.7 || tar zxf nginx-1.19.7.tar.gz
cd nginx-1.19.7

./configure \
--with-debug \
--prefix=/opt/nginx \
--with-cc-opt="-static -static-libgcc" \
--with-ld-opt="-static" \
--with-cpu-opt=generic \
--with-pcre=../pcre-8.44 \
--with-zlib=../zlib-1.2.11 \
--with-http_ssl_module \
--with-compat \
--with-file-aio \
--with-threads \
--with-http_addition_module \
--with-http_auth_request_module \
--with-http_slice_module \
--with-http_sub_module \
--with-http_v2_module \
--with-mail \
--with-mail_ssl_module \
--with-stream \
--with-stream_realip_module \
--with-stream_ssl_module \
--with-stream_ssl_preread_module \
--with-poll_module \
--with-select_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_auth_request_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_degradation_module \
--with-http_stub_status_module 

make -j1
