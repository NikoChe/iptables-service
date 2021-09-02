#!/bin/sh

IP4TABLES_BIN=/sbin/iptables
IP6TABLES_BIN=/sbin/ip6tables

# Flush active rules, flush custom tables, and set default policy
Flush_Rules () {
	if [ $1 = "ipv6" ]; then
		IPTABLES=$IP6TABLES_BIN
	else
		IPTABLES=$IP4TABLES_BIN
	fi
	$IPTABLES --flush
	$IPTABLES -t nat --flush
	$IPTABLES -t mangle --flush
	$IPTABLES --delete-chain
	$IPTABLES -t nat --delete-chain
	$IPTABLES -t mangle --delete-chain
	# Set default policies to ACCEPT
	$IPTABLES -P INPUT ACCEPT
	$IPTABLES -P FORWARD ACCEPT
	$IPTABLES -P OUTPUT ACCEPT
}

# Loading rules
Load_Rules () {
	if [ $1 = "ipv6" ]; then
		IPTABLES=$IP6TABLES_BIN
		IPV='IPv6'
	else
		IPTABLES=$IP4TABLES_BIN
		IPV='IPv4'
	fi
	# Flush
	Flush_Rules $1
	# Localhost
	$IPTABLES -A INPUT  -i lo -j ACCEPT
	$IPTABLES -A OUTPUT -o lo -j ACCEPT
	#VPN
	#$IPTABLES -A INPUT -i wg0 -j ACCEPT
	#$IPTABLES -A OUTPUT -o wg0 -j ACCEPT
	# Default policies
	$IPTABLES -P INPUT DROP
	$IPTABLES -P FORWARD DROP
	$IPTABLES -P OUTPUT ACCEPT
	# Input filter chain
	$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
	#SSH
	$IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT
	#WEB
	#$IPTABLES -A INPUT -p tcp --dport 80 -j ACCEPT
	#WEB-SSL
	#$IPTABLES -A INPUT -p tcp --dport 443 -j ACCEPT
	#DNS
	#$IPTABLES -A INPUT -p tcp --dport 53 -j ACCEPT
	#$IPTABLES -A INPUT -p udp --dport 53 -j ACCEPT

	#
	$IPTABLES -A INPUT -j LOG --log-prefix "${IPV}Tables INPUT Dropped:"
	# Forward chain
	$IPTABLES -A FORWARD -j LOG --log-prefix "${IPV}Tables FORWARD Dropped:"
	# disable furtive port scanning
	$IPTABLES -N PORT-SCAN
	$IPTABLES -A PORT-SCAN -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j RETURN
	$IPTABLES -A PORT-SCAN -j DROP
}

case $1 in
	start)
		Load_Rules ipv4
		Load_Rules ipv6
		echo "IPTables rules loaded."
		;;
	stop)
		Flush_Rules ipv4
		Flush_Rules ipv6
		echo "IPTables rules flushed."
		;;
	restart)
		Flush_Rules ipv4
		Flush_Rules ipv6
		Load_Rules ipv4
		Load_Rules ipv6
		echo "IPTables rules reloaded."
		;;
	*)
		echo "Usage: systemctl {start|stop|restart} iptables.service"
		exit 1
esac

exit 0
