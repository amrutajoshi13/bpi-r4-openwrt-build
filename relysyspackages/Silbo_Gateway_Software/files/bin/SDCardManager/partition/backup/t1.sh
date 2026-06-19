#!/bin/bash
$(scp /home/shakthi/shakthi_workspace/SDCardManager/SDCardManager.sh root@192.168.0.24:/root/SDCardSrc_02/SDCardManager/)
$(scp /home/shakthi/shakthi_workspace/SDCardManager/partitions_4gb.fdisk root@192.168.0.24:/root/SDCardSrc_02/SDCardManager/)
$(scp /home/shakthi/shakthi_workspace/SDCardManager/partitions_8gb.fdisk root@192.168.0.24:/root/SDCardSrc_02/SDCardManager/)
sleep 1
echo "logging in.....   "
sleep 1
/usr/bin/expect <(cat << EOA
spawn ssh -t root@192.168.0.24 "sh /root/SDCardSrc_02/SDCardManager/SDCardManager.sh 4GB ;df -h"
expect "password:"
send "5UN1uX@321\r"
interact
EOA
)
