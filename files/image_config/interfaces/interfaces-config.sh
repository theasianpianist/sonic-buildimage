#!/bin/bash

ifdown --force eth0

if [ -z "$(ip netns)"]; then
	sonic-cfggen -d -t /usr/share/sonic/templates/interfaces.j2 > /etc/network/interfaces 
else
	for NS in `seq 0 5`; do
		INTF=`redis-cli $NS -n 4 KEYS 'LOOPBACK_INTERFACE|Loopback0|*'`
		IFS='|' read -ra ADDR_ARRAY <<< "$INTF"
		ADDR=${ADDR_ARRAY[2]}	
		namespace $NS ip addr add $ADDR dev lo
	done
fi

[ -f /var/run/dhclient.eth0.pid ] && kill `cat /var/run/dhclient.eth0.pid` && rm -f /var/run/dhclient.eth0.pid

systemctl restart networking

ifdown lo && ifup lo
