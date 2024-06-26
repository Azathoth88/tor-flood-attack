#!/bin/bash

# Konfiguriere Tor
cat << EOF > /etc/tor/torrc
SocksPort 0.0.0.0:9050
ControlPort 9051
CookieAuthentication 0
HashedControlPassword 16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C
EOF

# Starte Tor
service tor start
sleep 5

# Überprüfe, ob Tor läuft
if service tor status | grep -q "tor is running"; then
    echo "Tor is running"
else
    echo "Failed to start Tor"
    exit 1
fi

# Konfiguriere Privoxy
cat << EOF > /etc/privoxy/config
listen-address  0.0.0.0:8118
forward-socks5 / 127.0.0.1:9050 .
EOF

# Starte Privoxy
service privoxy start
sleep 5

# Überprüfe, ob Privoxy läuft
if service privoxy status | grep -q "privoxy is running"; then
    echo "Privoxy is running"
else
    echo "Failed to start Privoxy"
    exit 1
fi

# Starte die Hauptanwendung
python3 -u main.py
