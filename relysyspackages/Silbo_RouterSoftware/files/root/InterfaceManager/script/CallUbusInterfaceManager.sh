#!/bin/sh

#
# PKG_RELEASE: 1.01
#

UbusScript="/usr/libexec/rpcd/interfacemanager"
InterfaceManagerMethod="$1"
InterfaceName="$2"

if [ "x$InterfaceName" = "x" ] || [ "x$InterfaceManagerMethod" = "x" ]
then 
    echo "invalid interface"
    exit 1
else
    /bin/echo "{'interface':'$InterfaceName'}" | "$UbusScript" call $InterfaceManagerMethod
    exit 0
fi

