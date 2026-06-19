  fdisk /dev/mmcblk0
  mkfs.ext3 /dev/mmcblk0p1
  mkdir /mnt/usb/AppSrc/
  mount /dev/mmcblk0p1 /mnt/usb/AppSrc
