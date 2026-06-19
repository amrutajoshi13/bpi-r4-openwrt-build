#!/bin/sh

. /lib/functions.sh

openvpnstop="/etc/init.d/openvpn stop"

openvpnstart="/etc/init.d/openvpn start"

openvpnrestart="/etc/init.d/openvpn restart"

openvpnstatus="/root/InterfaceManager/script/vpn/openvpn/openvpnstatus.sh"

openvpn_config="/root/InterfaceManager/script/vpn/openvpn/openvpn_config.sh"

openvpn_bridge="/root/InterfaceManager/script/vpn/openvpn/openvpn_bridge.sh"

EnableOpenvpn=$(uci get vpnconfig1.general.enableopenvpngeneral)

NMS_Enable=$(uci get remoteconfig.nms.nmsenable)

if [ "$NMS_Enable" = "1" ] && [ "$EnableOpenvpn" = "0" ]; then

    response=$($openvpnstart)
    echo "The If part is executed"
    sed -i '/openvpnstatus.sh/d' /etc/crontabs/root

elif [ "$EnableOpenvpn" = "1" ]; then
    response=$($openvpn_config)

    response=$($openvpn_bridge)

    response=$($openvpnstart)
    echo "The elif part is executed"
    response=$($openvpnstatus)

    sed -i '/openvpnstatus.sh/d' /etc/crontabs/root
    echo "*/1 * * * * /root/InterfaceManager/script/vpn/openvpn/openvpnstatus.sh" >> /etc/crontabs/root

    /etc/init.d/cron restart
    # uci delete firewall.openvpn
    # uci set firewall.openvpn=zone
    # uci set firewall.openvpn.name="tun"
    # uci set firewall.openvpn.input="ACCEPT"
    # uci set firewall.openvpn.output="ACCEPT"
    # uci set firewall.openvpn.forward="ACCEPT"
    # uci set firewall.openvpn.device="tun+"
    # uci set firewall.openvpn.masq="1"
    # uci set firewall.openvpn.mtu_fix="1"

else
    response=$($openvpn_config)

    response=$($openvpnstop)
    echo "The else part is executed"
    response=$($openvpnstatus)

    sed -i '/openvpnstatus.sh/d' /etc/crontabs/root
    #uci delete firewall.openvpn
fi

response=$($openvpn_bridge)

sleep 4

response=$($openvpnstop)

sleep 5

response=$($openvpnstart)
