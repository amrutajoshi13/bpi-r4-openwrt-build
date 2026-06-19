#!/bin/sh
 
LOG="/root/install_log.txt"
 
echo "=================================" | tee -a "$LOG"
echo "=== Starting Installation ===" | tee -a "$LOG"
echo "=================================" | tee -a "$LOG"
 
# --------------------------------------------------
# Stop dependent services
# --------------------------------------------------
echo "[0/3] Stopping dependent services..." | tee -a "$LOG"
 
/etc/init.d/mosquitto stop 2>/dev/null
/etc/init.d/ttyd stop 2>/dev/null
 
sleep 2
 
# --------------------------------------------------
# Remove old libwebsockets
# --------------------------------------------------
echo "[1/3] Removing libwebsockets-openssl..." | tee -a "$LOG"
 
opkg remove --force-depends libwebsockets-openssl >> "$LOG" 2>&1
 
sleep 3   # IMPORTANT
 
# --------------------------------------------------
# Install libwebsockets-full
# --------------------------------------------------
echo "[2/3] Installing libwebsockets-full..." | tee -a "$LOG"
 
opkg install /root/libwebsockets-full_3.1.0-1_mipsel_24kc.ipk >> "$LOG" 2>&1
 
sleep 3   # IMPORTANT
 
# --------------------------------------------------
# Install ttyd
# --------------------------------------------------
echo "[3/3] Installing ttyd..." | tee -a "$LOG"
 
opkg install /root/ttyd_1.5.2-1_mipsel_24kc.ipk >> "$LOG" 2>&1
 
sleep 2
 
# --------------------------------------------------
# Restart services
# --------------------------------------------------
echo "Restarting services..." | tee -a "$LOG"
 
/etc/init.d/mosquitto start 2>/dev/null
/etc/init.d/ttyd start 2>/dev/null
 
# --------------------------------------------------
# Modify hotplug script
# --------------------------------------------------
echo "Updating hotplug script..." | tee -a "$LOG"
 
if [ -f /etc/hotplug.d/tty/01-CWAN1 ]; then
    sed -i '/env >> \/tmp\/envfile.txt/d' /etc/hotplug.d/tty/01-CWAN1
    echo "Hotplug script updated successfully." | tee -a "$LOG"
else
    echo "Hotplug file not found. Skipping." | tee -a "$LOG"
fi
 
rm -f /tmp/envfile.txt
 
echo "=================================" | tee -a "$LOG"
echo "=== Installation Process Finished ===" | tee -a "$LOG"
echo "Rebooting device..." | tee -a "$LOG"
echo "=================================" | tee -a "$LOG"
 
sync
sleep 3

reboot
 
exit 0
