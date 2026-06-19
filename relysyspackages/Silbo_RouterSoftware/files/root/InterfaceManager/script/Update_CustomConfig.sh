#!/bin/sh
mkdir -p /mnt/image
mkfs.vfat /dev/mtdblock7
mount -t vfat /dev/mtdblock7 /mnt/image/ 
cp /root/custom_image/custom_logo.svg /www/luci2/icons/
cp /root/custom_image/custom_logo.svg /mnt/image/
cp /etc/config/customconfig /mnt/image/
cp /etc/config/customconfig /root/InterfaceManager/config/
chmod 777 /www/luci2/icons/custom_logo.svg
Model=$(uci get customconfig.customconfig.CustomModelname)
uci set boardconfig.board.model="$Model"
uci set system.system.model="$Model"
manufacturer=$(uci get customconfig.customconfig.manufacturer)
manufacturer_url=$(uci get customconfig.customconfig.manufacturer_url)
uci set easycwmp.@device[0].manufacturer="$manufacturer"                                     
uci commit easycwmp
device_info="/etc/device_info"

MANUFACTURER=$(grep -w "DEVICE_MANUFACTURER" ${device_info})        
MANUFACTURER_Replace="DEVICE_MANUFACTURER=$manufacturer"
sed -i "s/${MANUFACTURER}/${MANUFACTURER_Replace}/" "$device_info"

MANUFACTURER_URL=$(grep -w "DEVICE_MANUFACTURER_URL" "$device_info")
MANUFACTURER_URL_Replace="DEVICE_MANUFACTURER_URL=$manufacturer_url"
sed -i "s|${MANUFACTURER_URL}|${MANUFACTURER_URL_Replace}|" "$device_info"

DEVICE_PRODUCT=$(grep -w "DEVICE_PRODUCT" ${device_info})        
DEVICE_PRODUCT_Replace="DEVICE_PRODUCT=$Model"
sed -i "s/${DEVICE_PRODUCT}/${DEVICE_PRODUCT_Replace}/" "$device_info"

uci commit boardconfig
uci commit system
/etc/init.d/uhttpd restart
umount /dev/mtdblock7
