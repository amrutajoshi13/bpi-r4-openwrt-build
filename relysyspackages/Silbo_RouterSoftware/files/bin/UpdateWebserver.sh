#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

webserverconfigUCIPath="/etc/config/webserverconfig"
webservertconfigsection="webserverconfig"
webserverconfigfile="/etc/config/uhttpd"
config_load "$webserverconfigUCIPath"
config_get Enable_http "$webservertconfigsection" enable_http
config_get http_port "$webservertconfigsection" http_port
config_get Enable_https "$webservertconfigsection" enable_https
config_get https_port "$webservertconfigsection" https_port
config_get rfc1918_filter "$webservertconfigsection" rfc1918_filter
config_get NtpSyncInterval "$webservertconfigsection" ntpsyncinterval
config_get EnableNtpSync "$webservertconfigsection" enablentpsync
config_get redirect_https "$webservertconfigsection" redirect_https

uci del uhttpd.main.listen_http
uci del uhttpd.main.listen_https
uci commit uhttpd

# config_get sessiontimeout "$webservertconfigsection" sessiontimeout
if [[ "$Enable_http" = '1' ]]           
then
uci set webserverconfig.webserverconfig.http_port="$http_port" 
uci add_list uhttpd.main.listen_http="0.0.0.0:$http_port"
uci add_list uhttpd.main.listen_http="[::]:$http_port"
else
uci delete uhttpd.main.listen_http
fi
if [[ "$Enable_https" = '1' ]]                         
then
uci set webserverconfig.webserverconfig.https_port="$https_port"  
uci add_list uhttpd.main.listen_https="0.0.0.0:$https_port"  
uci add_list uhttpd.main.listen_https="[::]:$https_port"
else                                                  
uci delete uhttpd.main.listen_https
fi
uci set uhttpd.main.rfc1918_filter="$rfc1918_filter"
uci set uhttpd.main.redirect_https="$redirect_https"

uci commit webserverconfig
uci commit uhttpd
sleep 1
/etc/init.d/uhttpd restart
sed -i '/TimeSync.sh/d' /etc/crontabs/root
if [[ "$EnableNtpSync" = '1' ]]                         
then
echo "*/$NtpSyncInterval * * * * /root/InterfaceManager/script/TimeSync.sh" >> /etc/crontabs/root
fi
/etc/init.d/cron restart
logger -t config -p customs.info "uhttpd configuration changed"

exit 0
