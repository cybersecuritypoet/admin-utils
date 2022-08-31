#!/bin/bash
CHOWN="/usr/bin/chown"
CHMOD="/usr/bin/chmod"
RSYNC="/usr/bin/rsync"
SYSTEMCTL="/usr/bin/systemctl"
$RSYNC -auv ./ /
$CHOWN root.root /opt/scripts/iostat-stats.sh
$CHMOD 700 /opt/scripts/iostat-stats.sh
$CHOWN root.root /etc/systemd/system/iostat-stats.service
$CHMOD 700 /etc/systemd/system/iostat-stats.service
$CHOWN root.root /etc/rsyslog.d/iostat-stats-socket.conf
$CHMOD 700 /etc/rsyslog.d/iostat-stats-socket.conf
$SYSTEMCTL daemon-reload