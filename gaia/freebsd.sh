#!/bin/sh
set -e -x

# Debug logging
# exec > /var/log/gaia-setup.log
# exec 2>&1

# Bootstrap pkg
env ASSUME_ALWAYS_YES=YES pkg bootstrap || true

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
make install

# Get testnet configuration
git clone https://github.com/tendermint/testnets /opt/testnets

# Create gaia-daemon user and set permissions
pw addgroup gaia-daemon
pw adduser gaia-daemon -g gaia-daemon -d /nonexistant -s /usr/sbin/nologin
touch /var/log/gaia.log
chown -R gaia-daemon:gaia-daemon /opt/testnets /var/log/gaia.log

# Create gaia service
cat > /etc/rc.d/gaia << "EOF"
#!/bin/sh

# REQUIRE: LOGIN FILESYSTEMS
. /etc/rc.subr

name="gaia"
rcvar=${name}_enable
pidfile="/var/run/${name}.pid"
command="/usr/sbin/daemon"
command_args="-f -u gaia-daemon -P ${pidfile} -o /var/log/gaia.log /opt/gopath/bin/gaia node start --home=/opt/testnets/gaia-2/gaia"

load_rc_config $name
run_rc_command "$1"
EOF
chmod +x /etc/rc.d/gaia
echo gaia_enable=YES >> /etc/rc.conf

# Finally reboot
reboot
