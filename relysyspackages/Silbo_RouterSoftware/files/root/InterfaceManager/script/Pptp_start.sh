#!/bin/sh

. /lib/functions.sh

ReadPptpConfigFile()
{
  vpnread="$1" 
  config_get PptpServer "$vpnread" pptpserver
  config_get PptpUserName "$vpnread" pptpuser
  config_get PptpPassword "$vpnread" pptppassword
}

UpdatePptpConfig()
{
   vpn="$1"	
   ReadPptpConfigFile "$vpn"
   
   if [ "$EnablePptp" = "1" ]
   then
    uci set network.PPTP=interface
	uci set network.PPTP.proto="pptp"
	uci set network.PPTP.server="$PptpServer"
	uci set network.PPTP.username="$PptpUserName"
	uci set network.PPTP.password="$PptpPassword"

	uci set firewall.pptp=zone
	uci set firewall.pptp.name='PPTP'
	uci set firewall.pptp.input='ACCEPT'
	uci set firewall.pptp.output='ACCEPT'
	uci set firewall.pptp.extra_src='-m policy --dir in --pol ipsec --proto esp'
	uci set firewall.pptp.extra_dest='-m policy --dir out --pol ipsec --proto esp'
	uci set firewall.pptp.mtu_fix='1'
	uci set firewall.pptp.forward='ACCEPT'
	uci set firewall.pptp.network='PPTP'
	
	uci set firewall.swlanpptp=forwarding
	uci set firewall.swlanpptp.src='SW_LAN'
	uci set firewall.swlanpptp.dest='PPTP'
	uci set firewall.pptpswlan=forwarding
	uci set firewall.pptpswlan.src='PPTP'
	uci set firewall.pptpswlan.dest='SW_LAN'
	uci set firewall.lan1pptp=forwarding
	uci set firewall.lan1pptp.src='LAN1'
	uci set firewall.lan1pptp.dest='PPTP'
	uci set firewall.pptplan1=forwarding
	uci set firewall.pptplan1.src='PPTP'
	uci set firewall.pptplan1.dest='LAN1'
	uci set firewall.lan2pptp=forwarding
	uci set firewall.lan2pptp.src='LAN2'
	uci set firewall.lan2pptp.dest='PPTP'
	uci set firewall.pptplan2=forwarding
	uci set firewall.pptplan2.src='PPTP'
	uci set firewall.pptplan2.dest='LAN2'
	uci set firewall.lan3pptp=forwarding
	uci set firewall.lan3pptp.src='LAN3'
	uci set firewall.lan3pptp.dest='PPTP'
	uci set firewall.pptplan3=forwarding
	uci set firewall.pptplan3.src='PPTP'
	uci set firewall.pptplan3.dest='LAN3'
	uci set firewall.lan4pptp=forwarding
	uci set firewall.lan4pptp.src='LAN4'
	uci set firewall.lan4pptp.dest='PPTP'
	uci set firewall.pptplan4=forwarding
	uci set firewall.pptplan4.src='PPTP'
	uci set firewall.pptplan4.dest='LAN4'
	uci set firewall.wifipptp=forwarding
	uci set firewall.wifipptp.src='WIFI'
	uci set firewall.wifipptp.dest='PPTP'
	uci set firewall.pptpwifi=forwarding
	uci set firewall.pptpwifi.src='PPTP'
	uci set firewall.pptpwifi.dest='WIFI'
   else
     uci delete network.PPTP > /dev/null 2>&1
     uci delete firewall.pptp > /dev/null 2>&1
     uci delete firewall.swlanpptp > /dev/null 2>&1
     uci delete firewall.pptpswlan > /dev/null 2>&1
     uci delete firewall.lan1pptp > /dev/null 2>&1
     uci delete firewall.pptplan1 > /dev/null 2>&1
     uci delete firewall.lan2pptp > /dev/null 2>&1
     uci delete firewall.pptplan2 > /dev/null 2>&1
     uci delete firewall.lan3pptp > /dev/null 2>&1
     uci delete firewall.pptplan3 > /dev/null 2>&1
     uci delete firewall.lan4pptp > /dev/null 2>&1
     uci delete firewall.pptplan4 > /dev/null 2>&1
     uci delete firewall.wifipptp > /dev/null 2>&1
     uci delete firewall.pptpwifi > /dev/null 2>&1
   fi
   uci commit network
   uci commit firewall
}


vpnconfigfile="/etc/config/vpnconfig1"


EnablePptp=$(uci get vpnconfig1.general.enablepptp)

config_load "$vpnconfigfile" 
config_foreach UpdatePptpConfig pptp

sleep 2

if [ "$EnablePptp" = "1" ]
then
ifdown PPTP > /dev/null 2>&1
sleep 5
ifup PPTP > /dev/null 2>&1
fi


