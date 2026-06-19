#!/bin/sh

CFG="/root/SourceAppComponent/etc/Config/AppManagerConfig.cfg"
RPCD="/etc/config/rpcd"

# map app name to acl
get_acl() {
    case "$1" in
        Modbus)  echo "deviceconfigV2" ;;
        RS232)   echo "rs232Config" ;;
        BACNET)  echo "BACnetConfig" ;;
        DIO)     echo "digitalinputConfig" ;;
        AIO)     echo "analoginputconfig" ;;
        SNMP)    echo "SnmpMasterConfig" ;;
        *)       echo "" ;;
    esac
}

while IFS='=' read -r app val; do
    acl=$(get_acl "$app")
    [ -z "$acl" ] && continue

    if [ "$val" = "1" ]; then
        # ENABLE ? remove !ACL
        sed -i "/list read '!\?$acl'/d" "$RPCD"
        sed -i "/list write '!\?$acl'/d" "$RPCD"
    else
        # DISABLE ? add !ACL (only if not exists)
        grep -q "list read '!$acl'" "$RPCD" || \
            sed -i "/list read '\*'/a\        list read '!$acl'" "$RPCD"

        grep -q "list write '!$acl'" "$RPCD" || \
            sed -i "/list write '\*'/a\        list write '!$acl'" "$RPCD"
    fi

done < "$CFG"

# restart rpcd to apply
# /etc/init.d/rpcd restart

echo "ACL updated based on AppManagerConfig.cfg"
