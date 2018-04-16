#!/bin/sh

get_subject() {
  if [ "$1" = "trusted" ]
  then
    echo "/C=IT/ST=Sicily/L=Catania/O=Redis/OU=Security/CN=127.0.0.1"
  else
    echo "/C=XX/ST=Untrusted/L=Evilville/O=Evil Hacker/OU=Attack Department/CN=127.0.0.1"
  fi
}

# Generate two CAs: one to be considered trusted, and one that's untrusted
for type in trusted untrusted; do
  rm -rf ./demoCA
  mkdir -p ./demoCA
  mkdir -p ./demoCA/certs
  mkdir -p ./demoCA/crl
  mkdir -p ./demoCA/newcerts
  mkdir -p ./demoCA/private
  touch ./demoCA/index.txt

  openssl genrsa -out ${type}-ca.key 2048
  openssl req -new -x509 -days 12500 -key ${type}-ca.key -out ${type}-ca.crt -subj "$(get_subject $type)"
  openssl x509 -in ${type}-ca.crt -noout -next_serial -out ./demoCA/serial

  openssl req -newkey rsa:2048 -keyout ${type}-cert.key -nodes -out ${type}-cert.req -subj "$(get_subject $type)"
  openssl ca -days 12500 -cert ${type}-ca.crt -keyfile ${type}-ca.key -out ${type}-cert.crt -infiles ${type}-cert.req
  rm ${type}-cert.req
done

rm -rf ./demoCA
