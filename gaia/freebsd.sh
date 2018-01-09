#!/bin/sh
set -e -x

# Bootstrap pkg
env ASSUME_ALWAYS_YES=YES pkg bootstrap

# Update packages - we'll reboot later on in case a this includes a kernel update
pkg upgrade -y

# Install dependencies
pkg install -y git-lite go
export GOPATH="/opt/gopath"
export PATH="$GOPATH/bin:$PATH"

# Install Gaia 0.5.0
go get github.com/cosmos/gaia || true
cd $GOPATH/src/github.com/cosmos/gaia
git checkout -qf v0.5.0
make get_vendor_deps
make install || true

# Get testnet configuration
git clone https://github.com/tendermint/testnets /opt/testnets
gaia node start --home=/opt/testnets/gaia-2/gaia
