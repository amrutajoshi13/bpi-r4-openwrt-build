#!/bin/sh
. /lib/functions.sh


DMZConfigFile="/etc/config/dmzconfig"

ReadDMZConfigFile()
{
        config_load "$DMZConfigFile"
        config_get enabledmz dmzconfig enabledmz
        config_get host_ip dmzconfig host_ip
        config_get proto dmzconfig proto
        config_get allow_http dmzconfig allow_http
        config_get ext_port_http dmzconfig ext_port_http
        config_get int_port_http dmzconfig int_port_http
        config_get allow_https dmzconfig allow_https
        config_get ext_port_https dmzconfig ext_port_https
        config_get int_port_https dmzconfig int_port_https
        config_get allow_ssh dmzconfig allow_ssh
        config_get ext_port_ssh dmzconfig ext_port_ssh
        config_get int_port_ssh dmzconfig int_port_ssh
        config_get allow_ftp dmzconfig allow_ftp
        config_get ext_port_ftp dmzconfig ext_port_ftp
        config_get int_port_ftp dmzconfig int_port_ftp
        config_get allow_dns dmzconfig allow_dns
        config_get ext_port_dns dmzconfig ext_port_dns
        config_get int_port_dns dmzconfig int_port_dns
      
}


UpdateDMZConfig()
{
	if [[ "$enabledmz" = "1" ]]
	then
	    uci set firewall.dmz=zone
	    uci set firewall.dmz.input='ACCEPT'
        uci set	firewall.dmz.output='ACCEPT'
        uci set firewall.dmz.forwarding='REJECT'
         
        
        if [[ "$allow_http" = "1" ]]
        then
            uci set firewall.dmz_http=redirect
            uci set firewall.dmz_http.enabled='1'
            uci set firewall.dmz_http.target='DNAT'
            uci set firewall.dmz_http.name='dmz_hhtp'
            uci set firewall.dmz_http.dest_ip="$host_ip"
            uci set firewall.dmz_http.proto="$proto"
            uci set firewall.dmz_http.src='EWAN5'
            uci set firewall.dmz_http.src_dport="$int_port_http"
            uci set firewall.dmz_http.family='ipv4'
            uci set firewall.dmz_http.dest='dmz'
            uci set firewall.dmz_http.dest_port="$ext_port_http"
        else
            uci delete firewall.dmz_http   
        fi
        
        if [[ "$allow_https" = "1" ]]
        then
            uci set firewall.dmz_https=redirect
            uci set firewall.dmz_https.enabled='1'
            uci set firewall.dmz_https.target='DNAT'
            uci set firewall.dmz_https.name='dmz_hhtps'
            uci set firewall.dmz_https.dest_ip="$host_ip"
            uci set firewall.dmz_https.proto="$proto"
            uci set firewall.dmz_https.src='EWAN5'
            uci set firewall.dmz_https.src_dport="$int_port_https"
            uci set firewall.dmz_https.family='ipv4'
            uci set firewall.dmz_https.dest='dmz'
            uci set firewall.dmz_https.dest_port="$ext_port_https"
        else
            uci delete firewall.dmz_https   
        fi
        
        if [[ "$allow_ssh" = "1" ]]
        then
            uci set firewall.dmz_ssh=redirect
            uci set firewall.dmz_ssh.enabled='1'
            uci set firewall.dmz_ssh.target='DNAT'
            uci set firewall.dmz_ssh.name='dmz_ssh'
            uci set firewall.dmz_ssh.dest_ip="$host_ip"
            uci set firewall.dmz_ssh.proto="$proto"
            uci set firewall.dmz_ssh.src='EWAN5'
            uci set firewall.dmz_ssh.src_dport="$int_port_ssh"
            uci set firewall.dmz_ssh.family='ipv4'
            uci set firewall.dmz_ssh.dest='dmz'
            uci set firewall.dmz_ssh.dest_port="$ext_port_ssh"
        else
            uci delete firewall.dmz_ssh   
        fi
        
        if [[ "$allow_ftp" = "1" ]]
        then
            uci set firewall.dmz_ftp=redirect
            uci set firewall.dmz_ftp.enabled='1'
            uci set firewall.dmz_ftp.target='DNAT'
            uci set firewall.dmz_ftp.name='dmz_ftp'
            uci set firewall.dmz_ftp.dest_ip="$host_ip"
            uci set firewall.dmz_ftp.proto="$proto"
            uci set firewall.dmz_ftp.src='EWAN5'
            uci set firewall.dmz_ftp.src_dport="$int_port_ftp"
            uci set firewall.dmz_ftp.family='ipv4'
            uci set firewall.dmz_ftp.dest='dmz'
            uci set firewall.dmz_ftp.dest_port="$ext_port_ftp"
        else
            uci delete firewall.dmz_ftp   
        fi
        
        if [[ "$allow_dns" = "1" ]]
        then
            uci set firewall.dmz_dns=redirect
            uci set firewall.dmz_dns.enabled='1'
            uci set firewall.dmz_dns.target='DNAT'
            uci set firewall.dmz_dns.name='dmz_dns'
            uci set firewall.dmz_dns.dest_ip="$host_ip"
            uci set firewall.dmz_dns.proto="$proto"
            uci set firewall.dmz_dns.src='EWAN5'
            uci set firewall.dmz_dns.src_dport="$int_port_dns"
            uci set firewall.dmz_dns.family='ipv4'
            uci set firewall.dmz_dns.dest='dmz'
            uci set firewall.dmz_dns.dest_port="$ext_port_dns"
        else
            uci delete firewall.dmz_dns   
        fi
        
    else
         uci delete firewall.dmz
         uci delete firewall.dmz_http
         uci delete firewall.dmz_https
         uci delete firewall.dmz_ssh
         uci delete firewall.dmz_ftp   
         uci delete firewall.dmz_dns
    fi     
        
   
    uci commit firewall
    
}

RestartInitScript()
{
	/etc/init.d/firewall restart
}

ReadDMZConfigFile
UpdateDMZConfig
RestartInitScript

exit 0

   
