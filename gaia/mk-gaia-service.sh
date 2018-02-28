#!/bin/bash -ex

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

cp monitor-gaia.sh /usr/bin
echo "* * * * * root /usr/bin/monitor-gaia.sh" > /etc/cron.d/monitor-gaia
