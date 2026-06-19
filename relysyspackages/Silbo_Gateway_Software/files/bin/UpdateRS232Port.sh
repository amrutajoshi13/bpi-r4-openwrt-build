#!/bin/sh

LOG="/tmp/rs232_autodetect.log"
UTILITY_CFG="/root/RS232UtilityComponent/etc/Config/RS232utilityConfig.cfg"
DEVICE_CFG="/root/RS232ReadAppComponent/etc/Config/RS232DeviceConfig.cfg"

echo "========== RS232 Auto Detect (Driver Based) ==========" > $LOG
date >> $LOG

TTY_DEVICE=""

# -------------------------------------------------
# Step 1: Detect ttyUSB with cp210x driver
# -------------------------------------------------

for tty in /sys/class/tty/ttyUSB*; do
    if [ -L "$tty/device/driver" ]; then
        DRIVER_NAME=$(basename $(readlink $tty/device/driver))
        
        echo "Checking $(basename $tty) → Driver: $DRIVER_NAME" >> $LOG
        
        if [ "$DRIVER_NAME" = "cp210x" ]; then
            TTY_DEVICE="/dev/$(basename $tty)"
            break
        fi
    fi
done

if [ -z "$TTY_DEVICE" ]; then
    echo "No CP210x ttyUSB found!" >> $LOG
    exit 1
fi

echo "Detected RS232 Port: $TTY_DEVICE" >> $LOG

# -------------------------------------------------
# Step 2: Update Utility Config
# -------------------------------------------------

if [ -f "$UTILITY_CFG" ]; then
    sed -i "s|SerialPort=.*|SerialPort=\"$TTY_DEVICE\"|g" "$UTILITY_CFG"
    echo "Updated $UTILITY_CFG" >> $LOG
fi

# -------------------------------------------------
# Step 3: Update Device Config
# -------------------------------------------------

if [ -f "$DEVICE_CFG" ]; then

    # Replace ANY SerialPort_X line (even empty "")
   # sed -i "s|^SerialPort_[0-9]*=.*|SerialPort_\\1=\"$TTY_DEVICE\"|g" "$DEVICE_CFG"
    sed -i "s|^SerialPort_\([0-9]*\)=.*|SerialPort_\1=\"$TTY_DEVICE\"|g" "$DEVICE_CFG"

    # BusyBox sed does not support backreference properly,
    # so safest method is loop through possible numbers

    for i in $(seq 1 10); do
        sed -i "s|^SerialPort_$i=.*|SerialPort_$i=\"$TTY_DEVICE\"|g" "$DEVICE_CFG"
    done

    echo "Updated $DEVICE_CFG" >> $LOG
fi

echo "RS232 Auto Detection Completed Successfully" >> $LOG
exit 0

