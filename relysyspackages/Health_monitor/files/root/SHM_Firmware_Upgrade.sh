#!/bin/sh
# Script: Firmware Download + Checksum Verify + Sysupgrade + Auto Reboot

# Example usage:
# sh /root/download_script.sh "00d7fd0d-b615-5587-947f-1592493c7c95,2728527,2,Y6618250008,openwrt-ramips-mt76x8-Silbo_RC44-squashfs-sysupgrade.bin,http://182.76.82.100/vegarouter/API/Router_Firmware/,900,19 M"

LOG_DIR="/root/Router_Logs/SHMAPP_Log"
LOG_FILE="$LOG_DIR/download_script_log.txt"
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

INPUT="$1"

# Split arguments using comma as delimiter
IFS=',' read -r cDeviceUUID cRetry bFileType cDeviceId cFileName cServerUrl cCheckSum cFileSize <<< "$INPUT"

cPathName="/tmp"

echo "==========================" >> "$LOG_FILE"
echo "[$(date)] Script started" >> "$LOG_FILE"
echo "Device UUID : $cDeviceUUID" >> "$LOG_FILE"
echo "Retry Count : $cRetry" >> "$LOG_FILE"
echo "File Type   : $bFileType" >> "$LOG_FILE"
echo "Device ID   : $cDeviceId" >> "$LOG_FILE"
echo "File Name   : $cFileName" >> "$LOG_FILE"
echo "Server URL  : $cServerUrl" >> "$LOG_FILE"
echo "Checksum    : $cCheckSum" >> "$LOG_FILE"
echo "File Size   : $cFileSize" >> "$LOG_FILE"

iRetryCount=0
bDownloadSuccessFlag=0
iMaxRetries=5

if [ "$bFileType" = "2" ]; then
    echo "[$(date)] Starting firmware download..." >> "$LOG_FILE"

    while [ $iRetryCount -lt $iMaxRetries ]; do
        echo "[$(date)] Attempt #$((iRetryCount + 1))" >> "$LOG_FILE"

        # Download firmware (resumable)
        cResponse=$(curl -C - -m 120 -o "$cPathName/$cFileName" --write-out '%{http_code}' -s "$cServerUrl/$cFileName")

        echo "[$(date)] HTTP Response: $cResponse" >> "$LOG_FILE"

        if [ "$cResponse" = "200" ] || [ "$cResponse" = "206" ]; then
            chmod 777 "$cPathName/$cFileName"

            # Compute checksum of downloaded file
            cPackageCheckSum=$(md5sum "$cPathName/$cFileName" | awk '{print $1}')

            echo "Expected Checksum: $cCheckSum" >> "$LOG_FILE"
            echo "Actual Checksum  : $cPackageCheckSum" >> "$LOG_FILE"

            if [ "$cPackageCheckSum" = "$cCheckSum" ]; then
                echo "[$(date)]  Checksum verified successfully!" >> "$LOG_FILE"
                echo "[$(date)] Running sysupgrade..." >> "$LOG_FILE"

                #/sbin/sysupgrade -n "$cPathName/$cFileName" >> "$LOG_FILE" 2>&1

                if [ $? -eq 0 ]; then
                    echo "[$(date)]  Sysupgrade completed successfully!" >> "$LOG_FILE"
                    bDownloadSuccessFlag=1
                    break
                else
                    echo "[$(date)]  Sysupgrade failed!" >> "$LOG_FILE"
                fi
            else
                echo "[$(date)] Checksum mismatch, retrying..." >> "$LOG_FILE"
            fi
        else
            echo "[$(date)]  Download failed with HTTP code $cResponse" >> "$LOG_FILE"
        fi

        iRetryCount=$((iRetryCount + 1))
        echo "[$(date)] Waiting 30 seconds before retry..." >> "$LOG_FILE"
        sleep 30
    done

    if [ $bDownloadSuccessFlag -eq 1 ]; then
        echo "[$(date)] ✅ Firmware upgrade successful, rebooting now..." >> "$LOG_FILE"
        sleep 10
        reboot
    else
        echo "[$(date)]  All retries failed, upgrade aborted." >> "$LOG_FILE"
    fi
else
    echo "[$(date)] File type $bFileType is not '2' (firmware). Exiting." >> "$LOG_FILE"
fi
