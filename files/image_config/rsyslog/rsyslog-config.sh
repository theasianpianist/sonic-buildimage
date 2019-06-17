#!/bin/bash

sonic-cfggen -s /var/run/redis/redis$1.sock -d -t /usr/share/sonic/templates/rsyslog.conf.j2 >/etc/rsyslog$1.conf
systemctl restart rsyslog
