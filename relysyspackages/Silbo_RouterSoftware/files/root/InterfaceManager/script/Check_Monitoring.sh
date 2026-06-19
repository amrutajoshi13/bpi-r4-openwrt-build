#!/bin/sh

. /lib/functions.sh

TmpFile="/tmp/openwisp/monitoring/"

FilePresent="X"

if [ -d "$TmpFile" ]
then
 FilePresent=$(ls -A "$TmpFile")
 if [ "$FilePresent" = "X" ]
 then
    echo "Directory is Empty"
 else
    rm -r /tmp/openwisp/monitoring/*
    echo "Delete files in Directory"
 fi
fi
