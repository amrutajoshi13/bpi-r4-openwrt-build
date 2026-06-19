#!/bin/sh


if ls /root/ConfigFiles/Logs/*.backup 1> /dev/null 2>&1; then

    echo "Backup files are present"
    rm -f /root/ConfigFiles/Logs/*.backup

else
    echo "No backup files found"
fi
