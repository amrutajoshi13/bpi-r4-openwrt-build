#!/bin/bash

# Source the library functions
. /lib/functions.sh

# Define the variables
FirmwareVer=$(uci get boardconfig.board.FirmwareVer)
ApplicationSwVer=$(uci get boardconfig.board.ApplicationSwVer)
#GWFirmwareVer=$(uci get boardconfig.board.GWFirmwareVer)
#GWApplicationSwVer=$(uci get boardconfig.board.GWApplicationSwVer)
GWFirmwareVer="1.0"
GWApplicationSwVer="1.0"

# Search for the string in the file and replace it with the variable values
sed -i "s/Firmware Version and IPK Version '\(.*\)'/[ L.tr('Firmware Version and IPK Version'), \"$FirmwareVer\_$ApplicationSwVer\_$GWFirmwareVer\_$GWApplicationSwVer\" ]/g" /www/luci2/view/status.overview.js

exit 0

