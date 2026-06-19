#!/bin/sh

uci set remoteconfig.general.rmsoption="none"
uci set remoteconfig.nms.nmsenable="0"
sleep 2
uci commit remoteconfig
uci set vpnconfig1.general.enableopenvpngeneral="0"
uci commit vpnconfig1
sleep 5
sh /root/InterfaceManager/script/Disable_Nms.sh
sleep 10