#!/bin/sh
. /lib/functions.sh

#modbusconfigUCIPath=/etc/config/modbusconfig
modbusconfigUCIPath=/etc/config/portconfig
#modbusconfigsection="modbusconfig"
modbusconfigsection1="portconfig1"
modbusconfigsection2="portconfig2"
mbusdconfigfile1=/etc/mbusdconfig.conf
mbusdconfigfile2=/etc/mbusdconfig2.conf
cronfile=/etc/crontab/root
ipaddress=0.0.0.0

port1mode=$(uci get sysconfig.sysconfig.port1mode)
EthernetProtocolswlan=$(uci get sysconfig.sysconfig.EthernetProtocolswlan)
EthernetServerDHCPIPswlan=$(uci get sysconfig.sysconfig.EthernetServerDHCPIPswlan)
EthernetServerStaticIPswlan=$(uci get sysconfig.sysconfig.EthernetServerStaticIPswlan)

port5mode=$(uci get sysconfig.sysconfig.port5mode)
EthernetProtocolPort5lan=$(uci get sysconfig.sysconfig.EthernetProtocolPort5lan)
EthernetServerDHCPIPPort5lan=$(uci get sysconfig.sysconfig.EthernetServerDHCPIPPort5lan)
EthernetServerStaticIPPort5lan=$(uci get sysconfig.sysconfig.EthernetServerStaticIPPort5lan)
EthernetProtocolPort5wan=$(uci get sysconfig.sysconfig.EthernetProtocolPort5wan)

EthernetProtocolPort1lan=$(uci get sysconfig.sysconfig.EthernetProtocolPort1lan)
EthernetServerDHCPIPPort1lan=$(uci get sysconfig.sysconfig.EthernetServerDHCPIPPortlan)
EthernetServerStaticIPPort1lan=$(uci get sysconfig.sysconfig.EthernetServerStaticIPPortlan)
Ser2netEnable1=$(uci get portconfig.portconfig1.Ser2netEnable1)
Ser2netEnable2=$(uci get portconfig.portconfig2.Ser2netEnable2)


EthernetProtocolPortwan=$(uci get sysconfig.sysconfig.EthernetProtocolPortwan)

config_load "$modbusconfigUCIPath"
config_get mbusdNoOfStopbits1 "$modbusconfigsection1" mbusdNoOfStopbits1
config_get mbusdtcpport1 "$modbusconfigsection1" mbusdtcpport1
config_get mbusdmaxretries1 "$modbusconfigsection1" mbusdmaxretries1
config_get mbusddelaybetweeneachrequest1 "$modbusconfigsection1" mbusddelaybetweeneachrequest1
config_get mbusdBaudrate1 "$modbusconfigsection1" mbusdBaudrate1
config_get mbusdDatabits1 "$modbusconfigsection1" mbusdDatabits1
config_get mbusdParity1 "$modbusconfigsection1" mbusdParity1
config_get mbusdresponsewaittime1 "$modbusconfigsection1" mbusdresponsewaittime1
config_get mbusdconnectiontimeout1 "$modbusconfigsection1" mbusdconnectiontimeout1
config_get mbusdLocalInterfaceIP1 "$modbusconfigsection1" mbusdLocalInterfaceIP1


config_get mbusdNoOfStopbits2 "$modbusconfigsection2" mbusdNoOfStopbits2
config_get mbusdtcpport2 "$modbusconfigsection2" mbusdtcpport2
config_get mbusdmaxretries2 "$modbusconfigsection2" mbusdmaxretries2
config_get mbusddelaybetweeneachrequest2 "$modbusconfigsection2" mbusddelaybetweeneachrequest2
config_get mbusdBaudrate2 "$modbusconfigsection2" mbusdBaudrate2
config_get mbusdDatabits2 "$modbusconfigsection2" mbusdDatabits2
config_get mbusdParity2 "$modbusconfigsection2" mbusdParity2
config_get mbusdresponsewaittime2 "$modbusconfigsection2" mbusdresponsewaittime2
config_get mbusdconnectiontimeout2 "$modbusconfigsection2" mbusdconnectiontimeout2
config_get mbusdLocalInterfaceIP2 "$modbusconfigsection2" mbusdLocalInterfaceIP2


# --------------------------------------------------
# Board Detection Logic
# --------------------------------------------------

# Read board ID from flash offset 0xF020
flash_val_f020=$(dd if=/dev/mtd2 bs=1 skip=$((0xF020)) count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')

# Read board subtype from flash offset 0xF021 (decimal)
flash_val_f021=$(dd if=/dev/mtd2 bs=1 skip=$((0xF021)) count=1 2>/dev/null | od -An -tu1 | tr -d ' ')

# Default values
[ -z "$flash_val_f020" ] && flash_val_f020="FF"
[ -z "$flash_val_f021" ] && flash_val_f021="255"

# Decide board name
case "$flash_val_f020" in
    0B)
        board_name="IDB54-C-GW"
        ;;
    0F)
        board_name="IDF54-C-GW"
        ;;
    47)
        case "$flash_val_f021" in
            88)
                board_name="silbo-IDG50-GW"
                ;;
            99)
                board_name="silbo-RVWG50-GW"
                ;;
            *)
                board_name="silbo-RVWG50-GW"
                ;;
        esac
        ;;
    *)
        board_name=$(cat /tmp/sysinfo/board_name)
        ;;
esac

echo "Detected Board Name : $board_name"

# Decide serial port
if echo "$board_name" | grep -qE "(IDG|RVWG)"
then
    SERIAL_PORT="/dev/ttyUSB0"
else
    SERIAL_PORT="/dev/ttyS1"
fi

echo "Using Serial Port : $SERIAL_PORT"


if [ "$Ser2netEnable1" -eq 0 ]
then 
	if [ $mbusdParity1 = '0' ]
	then
	paritytobeupdated1='n'
	elif [ $mbusdParity1 = '1' ]
	then
	paritytobeupdated1='o'
	elif [ $mbusdParity1 = '2' ]
	then
	paritytobeupdated1='e'
	fi

	modetobeupdated1=$mbusdDatabits1$paritytobeupdated1$mbusdNoOfStopbits1
	echo "modetobeupdated1 = $modetobeupdated1"
	
	#echo "port1mode=$port1mode"
	#echo "EthernetProtocolPort1lan=$EthernetProtocolPort1lan"
	#echo "EthernetServerStaticIPPort1lan=$EthernetServerStaticIPPort1lan"
      
    echo $mbusdLocalInterfaceIP1	   
    sed -i "/address =/c\address = $mbusdLocalInterfaceIP1" "$mbusdconfigfile1"                
                                  
	echo "ipaddress = $ipaddress"
	sed -i "/device =/c\device = $SERIAL_PORT" "$mbusdconfigfile1"
	sed -i "/speed =/c\speed = $mbusdBaudrate1" "$mbusdconfigfile1"
	sed -i "/mode =/c\mode = $modetobeupdated1" "$mbusdconfigfile1"
	sed -i "/port =/c\port = $mbusdtcpport1" "$mbusdconfigfile1"
	sed -i "/retries =/c\retries = $mbusdmaxretries1" "$mbusdconfigfile1"
	sed -i "/pause =/c\pause = $mbusddelaybetweeneachrequest1" "$mbusdconfigfile1"
	sed -i "/wait =/c\wait = $mbusdresponsewaittime1" "$mbusdconfigfile1"
	sed -i "/timeout =/c\timeout = $mbusdconnectiontimeout1" "$mbusdconfigfile1"
	sed -i '\|runMbusdlogrotate.sh|d' "$cronfile"
	echo "* */5 * * * sh /bin/runMbusdlogrotate.sh" >> "$cronfile"
	/etc/init.d/crond restart
fi


if [ "$Ser2netEnable2" -eq 0 ]
then 
	if [ $mbusdParity2 = '0' ]
	then
	paritytobeupdated2='n'
	elif [ $mbusdParity2 = '1' ]
	then
	paritytobeupdated2='o'
	elif [ $mbusdParity2 = '2' ]
	then
	paritytobeupdated2='e'
	fi

	modetobeupdated2=$mbusdDatabits2$paritytobeupdated2$mbusdNoOfStopbits2
	echo "modetobeupdated2 = $modetobeupdated2"

	sed -i "/address =/c\address = $mbusdLocalInterfaceIP2" "$mbusdconfigfile2"                       
	          	     
	echo "ipaddress = $ipaddress"
	
	sed -i "/speed =/c\speed = $mbusdBaudrate2" "$mbusdconfigfile2"
	sed -i "/mode =/c\mode = $modetobeupdated2" "$mbusdconfigfile2"
	sed -i "/port =/c\port = $mbusdtcpport2" "$mbusdconfigfile2"
	sed -i "/retries =/c\retries = $mbusdmaxretries2" "$mbusdconfigfile2"
	sed -i "/pause =/c\pause = $mbusddelaybetweeneachrequest2" "$mbusdconfigfile2"
	sed -i "/wait =/c\wait = $mbusdresponsewaittime2" "$mbusdconfigfile2"
	sed -i "/timeout =/c\timeout = $mbusdconnectiontimeout2" "$mbusdconfigfile2"
	sed -i '\|runMbusdlogrotate.sh|d' "$cronfile"
	echo "* */5 * * * sh /bin/runMbusdlogrotate.sh" >> "$cronfile"
	/etc/init.d/crond restart
fi
