#!/bin/bash
cp systemd-iptables.sh /etc/systemd-iptables.sh  &&
cp iptables.service /etc/systemd/system/iptables.service &&
systemctl daemon-reload &&
systemctl enable iptables.service &&
systemctl start iptables.service &&
exit
