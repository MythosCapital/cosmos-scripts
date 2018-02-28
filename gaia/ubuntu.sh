#!/bin/bash -ex

# Install Go 1.9.2
cd /tmp
wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz
export GOPATH=/opt/gopath
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# install make
apt install make

# Install Gaia 0.5.0
go get github.com/cosmos/gaia || true
cd "$GOPATH/src/github.com/cosmos/gaia"
git checkout -qf v0.5.0
make get_vendor_deps
make install

# Get testnet configuration
git clone https://github.com/tendermint/testnets /opt/testnets

./mk-gaia-service.sh
