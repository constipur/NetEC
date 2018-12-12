#!/bin/bash
# arp table
sudo arp -s 10.0.0.3 68:91:d0:61:b4:c4
sudo arp -s 10.0.0.4 68:91:d0:61:12:3a
sudo arp -s 10.0.0.5 68:91:d0:61:12:5a
sudo arp -s 10.0.0.6 68:91:d0:61:12:4b
# arp table for tofino
sudo arp -s 10.0.0.10 11:22:33:44:55:66
# tx off
sudo ethtool -K $IF_40GBE tx off
# set mss
sudo ip route add 10.0.0.0/24 dev $IF_40GBE advmss 48
sudo ip route change 10.0.0.0/24 dev $IF_40GBE advmss 48
