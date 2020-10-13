#!/bin/bash
# save this file to ${HOME}/.config/clash/stop-clash.sh

# read pid file
PID=`cat /etc/clash/clash.pid`
kill -9 ${PID}
rm /etc/clash/clash.pid
