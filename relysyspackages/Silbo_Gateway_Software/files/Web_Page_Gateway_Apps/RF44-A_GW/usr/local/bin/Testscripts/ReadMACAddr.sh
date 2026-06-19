#!/bin/sh

wan_mac_addr=$(hexdump -v -n 6 -s 0x2e -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
lan_mac_addr=$(hexdump -v -n 6 -s 0x28 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
wifi_mac_addr=$(hexdump -v -n 6 -s 0x4 -e '5/1 "%02X:" 1/1 "%02X"' /dev/mtd2)
serial_n=$(hexdump -v -n 6 -s 0x100 -e '5/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
serial_number=${serial_n:0}
imei_n=$(hexdump -v -n 8 -s 0x110 -e '7/1 "%02X:" 1/1 "%01X"' /dev/mtd2 | sed 's/://g')
imei=${imei_n:0}

echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The serial number is - $serial_number" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The IMEI number is - $imei" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The wan mac addr is - $wan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The lan mac addr is - $lan_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "The wifi mac addr is - $wifi_mac_addr" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo "======================================" | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt
echo " " | tee -a /usr/local/bin/Testscripts/Testresult/ReadMACAddr.txt

#Wifi SSID 
#wifi_ssid="SILBO_RC44_$serial_number"
#wifi_guest_ssid="SILBO_RC44_GUEST_$serial_number"

board_name=$(cat /tmp/sysinfo/board_name)
board_name=$(echo "$board_name" | tr "-" "_")
wifi_ssid="${board_name}_$serial_number"
wifi_guest_ssid="S{board_name}_GUEST_$serial_number"

#Update the required parameters in config files.
uci set boardconfig.board.serialnum=$serial_number
uci set boardconfig.board.wanmacid=$wan_mac_addr
uci set boardconfig.board.lanmacid=$lan_mac_addr
uci set boardconfig.board.wifimacid=$wifi_mac_addr
uci set boardconfig.board.imei=$imei
uci commit boardconfig

sleep 1

cp /etc/config/boardconfig /root/InterfaceManager/config/boardconfig

sleep 1

uci set sysconfig.sysconfig.wifi1ssid=$wifi_ssid
uci commit sysconfig

sleep 1

uci set system.system.hostname=$serial_number
uci commit system

sleep 1

uci set wireless.ap.ssid=$wifi_ssid
uci commit wireless

sleep 1
uci set sysconfig.sysconfig.port5macid=$wan_mac_addr
uci set network.EWAN2.macaddr=$wan_mac_addr

uci commit sysconfig
uci commit network
sleep 1
/etc/init.d/network restart
#Update SSID in mt7628.dat file.
wirelessdatfile="/etc/wireless/mt7628/mt7628.dat"
ssid=$(grep -w "SSID1" ${wirelessdatfile})        
ssid_replace="SSID1=$wifi_ssid"
sed -i "s/${ssid}/${ssid_replace}/" "$wirelessdatfile"

ssid_guest=$(grep -w "SSID2" ${wirelessdatfile})        
ssid_guest_replace="SSID2=$wifi_guest_ssid"
sed -i "s/${ssid_guest}/${ssid_guest_replace}/" "$wirelessdatfile"
