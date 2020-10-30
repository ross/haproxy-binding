#!/bin/bash

set -e

# Create the dummy interface
echo "Creating dummy0"
ip link add dummy0 type dummy

# Add additional IP addresses
echo "Binding extra ips"
ip address add 192.168.42.43/32 dev dummy0
ip address add 192.168.42.44/32 dev dummy0
ip address add 192.168.42.45/32 dev dummy0

# Start up with a config that uses them all
echo "with all"
ln -s /app/haproxy-with.cfg /app/haproxy.cfg
/usr/local/sbin/haproxy -C /app -W -f /app/haproxy.cfg -p /app/haproxy.pid &
sleep 2
curl -sS http://192.168.42.43/ && echo "43 worked"
curl -sS http://192.168.42.44/ && echo "44 worked"
curl -sS http://192.168.42.45/ && echo "45 worked"
curl -sS http://127.0.0.1:81/ > /dev/null && echo "stats worked"

# Remove the first one
echo "Removing 43, switching to without"
ip address del 192.168.42.43/32 dev dummy0
# Switch to config that only uses the remaining 2
rm /app/haproxy.cfg
ln -s /app/haproxy-without.cfg /app/haproxy.cfg
kill -USR2 $(cat /app/haproxy.pid)
sleep 2
curl -sS http://192.168.42.44/ && echo "44 worked"
curl -sS http://192.168.42.45/ && echo "45 worked"
curl -sS http://127.0.0.1:81/ > /dev/null && echo "stats worked"

# Switch back to the original config, noting that we don't have one of its IPs available
echo "Switching back to with, .43 doesn't exist"
rm /app/haproxy.cfg
ln -s /app/haproxy-with.cfg /app/haproxy.cfg
kill -USR2 $(cat /app/haproxy.pid)
sleep 2
curl -sS http://192.168.42.44/ && echo "44 worked" || echo "*** 44 failed ***" && true
curl -sS http://192.168.42.45/ && echo "45 worked" || echo "*** 45 failed ***" && true
curl -sS http://127.0.0.1:81/ > /dev/null && echo "stats worked" || echo "*** stats failed ***" && true

# Shutdown haproxy
kill $(cat /app/haproxy.pid)
