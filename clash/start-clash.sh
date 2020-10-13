#!/bin/bash
# save this file to ${HOME}/.config/clash/start-clash.sh

# save pid file
echo $$ > /etc/clash/clash.pid

/usr/bin/clash -d /etc/clash
