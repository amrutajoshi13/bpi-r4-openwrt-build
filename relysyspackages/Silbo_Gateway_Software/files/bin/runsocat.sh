#!/bin/sh

. /lib/functions.sh

RemoteIP=$(uci get portconfig.portconfig1.remoteserverip1)
RemotePort=$(uci get portconfig.portconfig1.remoteserverport1)
#localipaddress=$(ifconfig eth0.1 | grep -o 'inet addr:[0-9.]\+' | awk -F: '{print $2}')
localPort=$(uci get portconfig.portconfig1.tcpport1)
localipaddress=$(uci get portconfig.portconfig1.LocalInterfaceIP1)

RemoteIP2=$(uci get portconfig.portconfig2.remoteserverip2)
RemotePort2=$(uci get portconfig.portconfig2.remoteserverport2)
#localipaddress=$(ifconfig eth0.1 | grep -o 'inet addr:[0-9.]\+' | awk -F: '{print $2}')
localPort2=$(uci get portconfig.portconfig2.tcpport2)
localipaddress2=$(uci get portconfig.portconfig2.LocalInterfaceIP2)

ser2netEnable1=$(uci get portconfig.portconfig1.Ser2netEnable1)
ser2netEnable2=$(uci get portconfig.portconfig2.Ser2netEnable2)

killall -9 ser2net
sleep 1

if [ "$ser2netEnable1" -eq 3 ]
then

/usr/sbin/ser2net -c /etc/ser2net.conf
sleep 2
/usr/bin/socat -v -x tcp:$localipaddress:$localPort tcp:$RemoteIP:$RemotePort > /dev/null 2>&1 &


fi

if [ "$ser2netEnable2" -eq 3 ]
then

/usr/sbin/ser2net -c /etc/ser2net2.conf
sleep 2
/usr/bin/socat -v -x tcp:$localipaddress2:$localPort2 tcp:$RemoteIP2:$RemotePort2 > /dev/null 2>&1 &


fi


exit 0
