#!/bin/sh
 
echo "Content-type: text/plain"
echo ""
ubus call file remove '{"path":"/root/EnergyMeterAppComponent/etc/Config/Alarms.txt"}'
ubus call file remove '{"path":"/root/EnergyMeterAppComponent/etc/Config/Events.txt"}'
