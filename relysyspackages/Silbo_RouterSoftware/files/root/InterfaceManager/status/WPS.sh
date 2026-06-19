#!/bin/sh

WpsEnable=$(uci get sysconfig.wificonfig.WpsEnable)
if [ "$WpsEnable" = "1" ]                                      
then
iwpriv ra0 set WscConfMode=7
iwpriv ra0 set WscMode=2
iwpriv ra0 set WscGetConf=1
elif [ "$WpsEnable" = "0" ]                                      
then
iwpriv ra0 set WscConfMode=7
iwpriv ra0 set WscMode=2
iwpriv ra0 set WscGetConf=0
fi
