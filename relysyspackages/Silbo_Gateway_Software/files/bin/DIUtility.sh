#!/bin/sh

#gpio_port="/root/ReadDIAppComponent/etc/Config/DIUtilityconfig.cfg"
gpio_port="$1"

DI_out=$(/root/DIUtilityIndividualTestComponent/DIUtilityIndividual "$1" 2>&1)

last_line=$(echo "$DI_out" | awk 'END{print}')

echo "$last_line"
