#!/bin/sh
# entrypoint.sh

# Modify resolv.conf at runtime
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo "DNSPort 9053" >> /etc/tor/torrc
sed "1s/^/SocksPort 0.0.0.0:9050\n/" /etc/tor/torrc.sample > /etc/tor/torrc

# Execute the original work command
exec "$@"
