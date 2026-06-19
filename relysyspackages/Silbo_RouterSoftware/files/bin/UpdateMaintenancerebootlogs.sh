#!/bin/sh

date=$(date)
RebootLogfile="/root/ConfigFiles/RebootLog/RebootLog.txt"
RebootreasonLogfile="/root/ConfigFiles/RebootLog/Rebootreason.txt"

echo "$date:[Maintenancereboot]:3" >> "$RebootLogfile"
echo "$date:[Maintenancereboot]:3" > "$RebootreasonLogfile"



