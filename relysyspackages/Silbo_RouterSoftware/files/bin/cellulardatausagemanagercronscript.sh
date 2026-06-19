#!/bin/sh
. /lib/functions.sh

ReadSysConfig()
{
  config_load "$sysconfigfile"
  config_get EnableCellular sysconfig enablecellular
}


sysconfigfile="/etc/config/sysconfig"

ReadSysConfig

if [ "$EnableCellular" = "1" ]
then
sed -i '/Data_Cap/d' /etc/crontabs/root
echo "*/2 * * * * /root/InterfaceManager/script/Data_Cap.sh" >> /etc/crontabs/root
exit 0
fi
