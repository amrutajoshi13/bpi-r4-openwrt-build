#!/bin/bash
$(scp  /home/shakthi/shakthi_workspace/SDCardManager/* root@192.168.0.24:/root/)
#$(scp  /home/shakthi/shakthi_workspace/SDCardManager/partitions_4gb.fdisk root@192.168.0.24:/root/)
#$(scp  /home/shakthi/shakthi_workspace/SDCardManager/partitions_8gb.fdisk root@192.168.0.24:/root/)

sleep 1
echo "logging in.....   "
sleep 1
/usr/bin/expect <(cat << EOA
spawn ssh -t root@192.168.0.24 "sh /root/SDCardManager.sh 4GB ;df -h"
expect "password:"
send "sunlux12\r"
interact
EOA
)

