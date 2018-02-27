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

touch /var/log/gaia.log
# Create gaia-daemon user and set permissions
useradd --system --shell /usr/sbin/nologin gaia-daemon
chown -R gaia-daemon:gaia-daemon /opt/testnets /var/log/gaia.log

# Create gaia.service
echo "[Unit]
Description=Cosmos Gaia Node
After=network-online.target

[Service]
User=gaia-daemon

# Need systemd 236 or later for the below
# ExecStart=/opt/gopath/bin/gaia node start --home=/opt/testnets/gaia-2/gaia
# StandardOutput=file:/var/log/gaia.log
# StandardError=file:/var/log/gaia.log

# .. so use this workaround instead:
ExecStart=/bin/sh -c '/opt/gopath/bin/gaia node start --home=/opt/testnets/gaia-3003/gaia 2>&1 > /var/log/gaia.log'

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/gaia.service
systemctl enable gaia.service
systemctl start gaia.service
