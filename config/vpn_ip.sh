#!/bin/bash
if pgrep -x openvpn >/dev/null
then
  # Display the IP address of the tun0 interface with a lock icon
  echo -n "🔒 "
  ip address | grep tun0 | grep inet | awk '{print $2}' | cut -d '/' -f1
else
  echo " VPN inactive."
fi