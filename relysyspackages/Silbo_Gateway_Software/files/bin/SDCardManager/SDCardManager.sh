#!/bin/sh

#default values
IotHubExplorerPath="/tmp/IoTHubExplorer/iothub-explorer"
TotalPartitions=4

InitTest()
{
    printf "Testing whether memory card is properly inserted or not\n"
#to verify sd card is present or not
    if [ $(ls /dev/mmcblk0) != "/dev/mmcblk0"  ] 
    then
        printf "SD Card is not inserted\n"
        exit 1
    fi
    printf "Verifying copied application source directories\n"
    printf "Verifying previously mounted partitions\n"
    if grep -qsw "AppSrc" /proc/mounts
    then
        printf "SD card partition is already mounted on AppSrc\n"
        exit 1
    fi

    if grep -qsw "AppData" /proc/mounts
    then
        printf "SD card partition is already mounted on AppData\n"
        exit 1
    fi
}

CreatePartitions()
{
    printf "Creating Partitions\n"
    #to create partition
    fdiskRetMsg=$( echo -e "n\np\n1\n2048\n2099199\nw\n^c\n" | fdisk /dev/mmcblk0)
    fdiskRetMsg1=$( echo -e "n\np\n2\n2099200\n4196351\nw\n^c\n" | fdisk /dev/mmcblk0)
    fdiskRetMsg2=$( echo -e "n\np\n3\n4196352\n6293503\nw\n^c\n" | fdisk /dev/mmcblk0)
    fdiskRetMsg3=$( echo -e "n\np\n4\n6293504\n7405567\nw^c\n" | fdisk /dev/mmcblk0)

    fdiskRetVal=$?
    if [ "$fdiskRetVal" != 0 ]
    then
        printf "failed to create partitions\n"
        printf "ErrorCode:%s,\nErrorMsg:%s\n" "$fdiskRetVal" "$fdiskRetMsg" "$fdiskRetMsg1" "$fdiskRetMsg2" "$fdiskRetMsg3"
        exit 1
    else
        printf "created partitions successfully\n\n"
        printf "fdiskRetVal:%s,\nfdiskRetMsg:%s\n\n" "$fdiskRetVal" "$fdiskRetMsg" "$fdiskRetMsg1" "$fdiskRetMsg2" "$fdiskRetMsg3"
    fi
}

FormatPartititons()
{
    printf "formatting partitions to ext4 file system\n"
    PartitionNo=1
    while [ $PartitionNo -le $TotalPartitions ]
    do
        PartitionName="/dev/mmcblk0p${PartitionNo}"
        #to create filesystem 
        FormatOutput=$(mkfs.ext4 $PartitionName 2>&1)
        FormatRetVal=$?
        if [ "$FormatRetVal" != 0 ]
        then
            printf "failed to format partition '%s'\n" "$PartitionName"
            printf "ErrorCode:%s,\nErrorMsg:%s\n" "$FormatRetVal" "$FormatOutput"
            exit 1
        else
            printf "formatted partition '%s' successfully\n\n" "$PartitionName"
            printf "FormatRetVal:%s,\nFormatOutput:%s\n\n" "$FormatRetVal" "$FormatOutput"
        fi
        PartitionNo=$((PartitionNo + 1))
    done
}

MountPartitions()
{
    printf "creating mount points\n"
    #create dir to allote space
    rm -rf /reap/disk/
    mkdir /reap/disk/
    mkdir /reap/disk/AppSrc/
    mkdir /reap/disk/AppData/
    mkdir /reap/disk/SDCard_Src1/
    mkdir /reap/disk/SDCard_Src2/
    #mount to allot space
    sleep 2
    #1gb
   # mount /dev/mmcblk0p1 /mnt/usb/AppTmp
	mount /dev/mmcblk0p1 /reap/disk/AppSrc
	sleep 4
	#1gb
	#mount /dev/mmcblk0p2 /mnt/usb/AppSrc
	mount /dev/mmcblk0p2 /reap/disk/AppData
	sleep 4
	#1gb
	#mount /dev/mmcblk0p3 /mnt/usb/AppData/
	mount /dev/mmcblk0p3 /reap/disk/SDCard_Src1
	sleep 4
	#543 mb
	#mount /dev/mmcblk0p4 /mnt/usb/Application/
	mount /dev/mmcblk0p4 /reap/disk/SDCard_Src2
    printf "Creating fstab file\n"
    
    mkdir /reap/disk/AppData/P500

cat <<EOF > /etc/config/fstab
config 'global' 'automount'
    option 'from_fstab' '1'
    option 'anon_mount' '0'

config 'mount'
    option 'target'   '/reap/disk/AppSrc'
    option 'device'   '/dev/mmcblk0p1'
    option 'fstype'   'ext4'
    option 'options'  'rw'
    option 'enabled'  '1'

config 'mount'
    option 'target'   '/reap/disk/AppData'
    option 'device'   '/dev/mmcblk0p2'
    option 'fstype'   'ext4'
    option 'options'  'rw'
    option 'enabled'  '1'

config 'mount'
    option 'target'   '/mnt/usb/SDCard_Src1'
    option 'device'   '/dev/mmcblk0p3'
    option 'fstype'   'ext4'
    option 'options'  'rw'
    option 'enabled'  '1'

config 'mount'
    option 'target'   '/reap/disk/SDCard_Src2'
    option 'device'   '/dev/mmcblk0p4'
    option 'fstype'   'ext4'
    option 'options'  'rw'
    option 'enabled'  '1'
EOF

    mkdir -p /reap/disk/AppData/P500/
    printf "enabling and restarting fstab/block-mount\n"
    /etc/init.d/fstab enable
    /etc/init.d/fstab start

    printf "Verifying newly mounted partitions\n"
    if ! grep -qsw "AppSrc" /proc/mounts
    then
        printf "SD card partition not mounted on AppSrc\n"
        exit 1
    fi
    if ! grep -qsw "AppData" /proc/mounts
    then
        printf "SD card partition not mounted on AppData\n"
        exit 1
    fi
    if ! grep -qsw "SDCard_Src1" /proc/mounts
    then
        printf "SD card partition not mounted on SDCard_Src1\n"
        exit 1
    fi
    if ! grep -qsw "SDCard_Src2" /proc/mounts
    then
        printf "SD card partition not mounted on SDCard_Src2\n"
        exit 1
    fi

    printf "SD card partitions mounted successfully\n"
    printf "Now creating directories for applications\n"

    mkdir /reap/disk/AppData/P500
}

UnmountPartition()
{
    for n in /dev/mmcblk0p* ; do umount $n ; done
    if [ $? -ne 0 ]
    then 
        printf "SD card Partitions are not mounted\n"
    else
        printf "Unmounted all SD card partitions successfully\n"
    fi
}
mmc=$1
#specify the total storage space
#4gb
if [ "$mmc" = "4GB" ]
then
    echo "using 4GB as memory card size"
    PartitionList="/bin/SDCardManager/partitions_4gb.sfdisk"
#8gb
elif [ "$mmc" = "8GB" ]
then
    echo "using 8GB as memory card size"
    PartitionList="/bin/SDCardManager/partitions_8gb.sfdisk"
else
    echo "no input arguments are provided, assuming 4GB as memory card size"
    PartitionList="/root/SDCardManager/partitions_4gb.sfdisk"
fi
#to call the fuctions
UnmountPartition
InitTest
CreatePartitions
FormatPartititons
MountPartitions

exit 0

