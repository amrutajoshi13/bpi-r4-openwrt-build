#!/bin/sh
wifilog="/etc/logrotate.d/wifilogrotate"
wifigtway=$(ifstatus WIFI_WAN | grep -i "nexthop" | cut -d "\"" -f 4)
PingOutput=$(ping -I apcli0 -c 5 -w 4 -A "$wifigtway" 2>&1)
PingOutput=$(echo "$PingOutput" | awk '/packets transmitted|received|packet loss|errors/')
PacketLoss=$(echo "$PingOutput" | awk -F , '{ for(i=1;i<=NF;i++)print $i }' |  awk '/loss/' | awk '{ print $1 }' | awk -F % '{ print $1 }')
date=$(date)
pid=$(pgrep -f "/var/run/udhcpc-apcli0.pid")
udhcpcSetFlag=$(uci get applist_config.appconfig.wifiudhcpcconfig)
if [ $udhcpcSetFlag = "0" ] && [ "$PacketLoss" != "100"] && [ "x$PacketLoss" != "x" ]
then
 echo "Wifi is Up"
 exit 0
fi

if [ "$PacketLoss" = "100" ] || [ "x$wifigtway" = "x" ] || [ "x$PacketLoss" = "x" ]
then
   uci set applist_config.appconfig.wifiudhcpcconfig=1
   uci commit applist_config
   udhcpcSetFlag=$(uci get applist_config.appconfig.wifiudhcpcconfig)
  if [ $udhcpcSetFlag = "1" ]
  then
    kill -SIGUSR2 $pid
    kill -SIGUSR1 $pid
    echo "$date wifi udhcpc is released and renewed" > /tmp/wifiudhcpclog
    uci set applist_config.appconfig.wifiudhcpcconfig=0
    uci commit applist_config
 fi
  wifi
date=$(date)
 echo "$date:wifi restarted" >> /root/ConfigFiles/Wifimonitorlogs/wifilog.txt
sleep 60
fi
logrotate "$wifilog"
exit 0
