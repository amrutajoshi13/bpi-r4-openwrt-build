#!/bin/sh

rm /www/healtha_all_parameters.json
sleep 1
touch /www/healtha_all_parameters.json
chmod 777 /www/healtha_all_parameters.json

userurl=$(uci get cloudconfigNH.cloudconfigNH.HTTPServerURL)
if [ "$userurl" = "2" ]; then
# Read JSON values from the local file
Jsonvalues=$(cat /root/Device_health/Device_health_value.txt)
# Split the values from the file using IFS (Internal Field Separator)
IFS=',' read -r Device_id DEVICE_MODEL combined_version Gateway_firmware_version Board_Type Ethernet_Wan_Mac formatted_uptime CPU_USAGE_AVG RAM_usage_total FLASH_usage_total WiFi_ssid num_DHCP_Lease WanSource deviceWANCount RouterWANporttimedetail RouterWANstatusdetail RouterWANuptimedetail RouterWANipdetail landetail Cellular_Mode SIMTYPE boardtotalport_str final_port_status CPIN_STATUS deviceqccid ACT_IMSI MOBILE_Operator Mobile_Operator_Code_B CREG_STATUS CGREG_STATUS NetworkType makecsqcombined RSRP_SINR_COMBO rsrqweb rssiweb cellid band mcc lac modemname frequency switch_Time1P switch_Time2P CPIN_STATUS2 deviceqccid2 ACT_IMSI2 MOBILE_Operator2 Mobile_Operator_Code_B2 CREG_STATUS2 CGREG_STATUS2 NetworkType2 makecsqcombined2 RSRP_SINR_COMBO2 rsrqweb2 rssiweb2 cellid2 band2 mcc2 lac2 modemname2 frequency2 Cellular_WAN_Interface_dailydata Cellular_WAN_Interface_monthdata LAST_Power_OFF_time reason Last_PowerON_time DEVICE_Temperature uuidk collectdatetime CPU_USAGE_AVG csqtype<<EOF
$Jsonvalues
EOF
# Create JSON output with the extracted values
output=$(cat <<EOF
{  
   "Device_ID": "$Device_id",
   "Device_Model": "$DEVICE_MODEL",
   "Router_Firmware_Version": "$combined_version",
   "Gateway_Firmware_Version": "$Gateway_firmware_version",
   "Device_Type": "$Board_Type",
   "Ethernet_WAN_MAC_ID": "$Ethernet_Wan_Mac",
   "System_Uptime": "$formatted_uptime",
   "Average_CPU_Usage": "$CPU_USAGE_AVG",
   "RAM_Usage": "$RAM_usage_total",
   "Flash_Usage": "$FLASH_usage_total",
   "WiFi_SSID": "$WiFi_ssid",
   "No_of_DHCP_Leases": "$num_DHCP_Lease",
   "Device_Wan_Type": "$WanSource",
   "DeviceWANCount": "$deviceWANCount",
   "Connection_Type": "$RouterWANporttimedetail",
   "Connection_Status": "$RouterWANstatusdetail",
   "Internet_Uptime": "$RouterWANuptimedetail",
   "Active_WAN_IP": "$RouterWANipdetail",
   "LAN_IP": "$landetail",
   "Cellular_Type": "$Cellular_Mode",
   "Num_SIM": "$SIMTYPE",
   "Device_Port": "$boardtotalport_str",
   "Device_Port_Status": "$final_port_status",
   "CPIN_Status": "$CPIN_STATUS",
   "ICCID": "$deviceqccid",
   "IMSI": "$ACT_IMSI",
   "Mobile_Operator_Name": "$MOBILE_Operator",
   "Mobile_Operator_Code": "$Mobile_Operator_Code_B",
   "CREG_Status": "$CREG_STATUS",
   "CGATT_Status": "$CGREG_STATUS",
   "SIM_RAT": "$NetworkType",
   "Mobile_Signal_CSQ": "$makecsqcombined",
   "RSRP_SINR": "$RSRP_SINR_COMBO",
   "RSRQ": "$rsrqweb",
   "RSSI": "$rssiweb",
   "CellID": "$cellid",
   "BAND": "$band",
   "MCC": "$mcc",
   "LAC": "$lac",
   "Modem_Name": "$modemname",
   "Frequency": "$frequency",
   "SIM_Switch1": "$switch_Time1P",
   "SIM_Switch2": "$switch_Time2P",
   "CPIN_Status2": "$CPIN_STATUS2",
   "ICCID2": "$deviceqccid2",
   "IMSI2": "$ACT_IMSI2",
   "Mobile_Operator_Name2": "$MOBILE_Operator2",
   "Mobile_Operator_Code2": "$Mobile_Operator_Code_B2",
   "CREG_Status2": "$CREG_STATUS2",
   "CGATT_Status2": "$CGREG_STATUS2",
   "SIM_RAT2": "$NetworkType2",
   "Mobile_Signal_CSQ2": "$makecsqcombined2",
   "RSRP_SINR2": "$RSRP_SINR_COMBO2",
   "RSRQ2": "$rsrqweb2",
   "RSSI2": "$rssiweb2",
   "CellID2": "$cellid2",
   "BAND2": "$band2",
   "MCC2": "$mcc2",
   "LAC2": "$lac2",
   "Modem_Name2": "$modemname2",
   "Frequency2": "$frequency2",
   "Cellular_WAN_Statistics_Daily": "$Cellular_WAN_Interface_dailydata",
   "Cellular_WAN_Statistics_Monthly": "$Cellular_WAN_Interface_monthdata",
   "Device_Last_PowerOFF_Time": "$LAST_Power_OFF_time",
   "Device_Last_PowerOFF_Reason": "$reason",
   "Device_Last_PowerON_Time": "$Last_PowerON_time",
   "Device_Temperature": "$DEVICE_Temperature",  
   "Device_UUID": "$uuidk",
   "Collect_Data_Time": "$collectdatetime",
    "Json_Data": {
    "CPU_avg": "$CPU_USAGE_AVG",
    "CSQ": "$csqtype"
    }
}
EOF
)
# Print the JSON output
echo "$output"  >> /www/healtha_all_parameters.json
else 
# Read JSON values from the local file
Jsonvalues=$(cat /root/Device_health/Device_health_value.txt)

# Split the values from the file using IFS (Internal Field Separator)
IFS=',' read -r Device_id DEVICE_MODEL combined_version Gateway_firmware_version Board_Type Ethernet_Wan_Mac formatted_uptime CPU_USAGE_AVG RAM_usage_total FLASH_usage_total WiFi_ssid num_DHCP_Lease WanSource deviceWANCount RouterWANporttimedetail RouterWANstatusdetail RouterWANuptimedetail RouterWANipdetail landetail Cellular_Mode SIMTYPE boardtotalport_str final_port_status CPIN_STATUS deviceqccid ACT_IMSI MOBILE_Operator Mobile_Operator_Code_B CREG_STATUS CGREG_STATUS NetworkType makecsqcombined RSRP_SINR_COMBO rsrqweb rssiweb cellid band mcc lac modemname frequency switch_Time1P switch_Time2P CPIN_STATUS2 deviceqccid2 ACT_IMSI2 MOBILE_Operator2 Mobile_Operator_Code_B2 CREG_STATUS2 CGREG_STATUS2 NetworkType2 makecsqcombined2 RSRP_SINR_COMBO2 rsrqweb2 rssiweb2 cellid2 band2 mcc2 lac2 modemname2 frequency2 Cellular_WAN_Interface_dailydata Cellular_WAN_Interface_monthdata LAST_Power_OFF_time reason Last_PowerON_time DEVICE_Temperature uuidk collectdatetime CPU_USAGE_AVG csqtype<<EOF
$Jsonvalues
EOF

# Create JSON output with the extracted values
output=$(cat <<EOF
{  
   "Device_ID": "$Device_id",
   "Device_Model": "$DEVICE_MODEL",
   "Router_Firmware_Version": "$combined_version",
   "Gateway_Firmware_Version": "$Gateway_firmware_version",
   "Device_Type": "$Board_Type",
   "Ethernet_WAN_MAC_ID": "$Ethernet_Wan_Mac",
   "System_Uptime": "$formatted_uptime",
   "Average_CPU_Usage": "$CPU_USAGE_AVG",
   "RAM_Usage": "$RAM_usage_total",
   "Flash_Usage": "$FLASH_usage_total",
   "WiFi_SSID": "$WiFi_ssid",
   "No_of_DHCP_Leases": "$num_DHCP_Lease",
   "Device_Wan_Type": "$WanSource",
   "DeviceWANCount": "$deviceWANCount",
   "Connection_Type": "$RouterWANporttimedetail",
   "Connection_Status": "$RouterWANstatusdetail",
   "Internet_Uptime": "$RouterWANuptimedetail",
   "Active_WAN_IP": "$RouterWANipdetail",
   "LAN_IP": "$landetail",
   "Cellular_Type": "$Cellular_Mode",
   "Num_SIM": "$SIMTYPE",
   "Device_Port": "$boardtotalport_str",
   "Device_Port_Status": "$final_port_status",
   "CPIN_Status": "$CPIN_STATUS",
   "ICCID": "$deviceqccid",
   "IMSI": "$ACT_IMSI",
   "Mobile_Operator_Name": "$MOBILE_Operator",
   "Mobile_Operator_Code": "$Mobile_Operator_Code_B",
   "CREG_Status": "$CREG_STATUS",
   "CGATT_Status": "$CGREG_STATUS",
   "SIM_RAT": "$NetworkType",
   "Mobile_Signal_CSQ": "$makecsqcombined",
   "RSRP_SINR": "$RSRP_SINR_COMBO",
   "RSRQ": "$rsrqweb",
   "RSSI": "$rssiweb",
   "CellID": "$cellid",
   "BAND": "$band",
   "MCC": "$mcc",
   "LAC": "$lac",
   "Modem_Name": "$modemname",
   "Frequency": "$frequency",
   "SIM_Switch1": "$switch_Time1P",
   "SIM_Switch2": "$switch_Time2P",
   "CPIN_Status2": "$CPIN_STATUS2",
   "ICCID2": "$deviceqccid2",
   "IMSI2": "$ACT_IMSI2",
   "Mobile_Operator_Name2": "$MOBILE_Operator2",
   "Mobile_Operator_Code2": "$Mobile_Operator_Code_B2",
   "CREG_Status2": "$CREG_STATUS2",
   "CGATT_Status2": "$CGREG_STATUS2",
   "SIM_RAT2": "$NetworkType2",
   "Mobile_Signal_CSQ2": "$makecsqcombined2",
   "RSRP_SINR2": "$RSRP_SINR_COMBO2",
   "RSRQ2": "$rsrqweb2",
   "RSSI2": "$rssiweb2",
   "CellID2": "$cellid2",
   "BAND2": "$band2",
   "MCC2": "$mcc2",
   "LAC2": "$lac2",
   "Modem_Name2": "$modemname2",
   "Frequency2": "$frequency2",
   "Cellular_WAN_Statistics_Daily": "$Cellular_WAN_Interface_dailydata",
   "Cellular_WAN_Statistics_Monthly": "$Cellular_WAN_Interface_monthdata",
   "Device_Last_PowerOFF_Time": "$LAST_Power_OFF_time",
   "Device_Last_PowerOFF_Reason": "$reason",
   "Device_Last_PowerON_Time": "$Last_PowerON_time",
   "Device_Temperature": "$DEVICE_Temperature",  
   "Device_UUID": "$uuidk",
   "Collect_Data_Time": "$collectdatetime",
    "Json_Data": {
    "CPU_avg": "$CPU_USAGE_AVG",
    "CSQ": "$csqtype"
    }
}
EOF
)
# Print the JSON output
echo "$output"  >> /www/healtha_all_parameters.json

fi
