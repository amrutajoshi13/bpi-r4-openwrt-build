#!/bin/bash

 uci set openwisp.http.uuid=''
 uci set openwisp.http.key=''
 uci set openwisp.http.shared_secret=''
 uci commit openwisp
 /etc/init.d/openwisp-config stop
 sleep 2
 /etc/init.d/openwisp-monitoring stop
 VPN_NAME=$(cat /etc/openwisp/remote/etc/config/openvpn | awk NR==1 | cut -d " " -f 3 | tr -d "'")
 uci delete openvpn.$VPN_NAME
 uci commit openvpn
 sleep 2
 /etc/init.d/openvpn restart
 
  cd /www/luci2/view/
  sed -i 's/NMS_enable_disable:true/NMS_enable_disable:false/' configuration.remotemonit.js
  /etc/init.d/uhttpd restart
