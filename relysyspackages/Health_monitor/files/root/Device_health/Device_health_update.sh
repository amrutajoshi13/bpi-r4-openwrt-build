#!/bin/sh

# Clean and prepare JSON output file
rm -f /www/health_parameter.json
touch /www/health_parameter.json
chmod 777 /www/health_parameter.json
sleep 1

OutputJSON="/www/health_parameter.json"
echo "{" >> "$OutputJSON"

# File paths
output_config_file="/etc/config/Health_Jsonconfig"
local_value_file="/root/Device_health/Device_health_value.txt"
index_output_file="/root/Device_health/JsonKeyParametersIndex.cfg"
mapping_output_file="/root/Device_health/JsonKeyParameters.cfg"

# Clear config output files
> "$index_output_file"
> "$mapping_output_file"

# Read local values (comma-separated values)
local_values=""
while IFS= read -r line; do
    local_values="$local_values$line,"
done < "$local_value_file"
local_values="${local_values%,}"  # remove trailing comma

# Total number of JsonRs485Indexconfig blocks
count=$(uci show Health_Jsonconfig | grep "=JsonRs485Indexconfig" | wc -l)
entry=0

while [ $entry -lt $count ]; do
    modbus_param=$(uci get Health_Jsonconfig.@JsonRs485Indexconfig[$entry].ModbusParameter 2>/dev/null)
    param_key=$(uci get Health_Jsonconfig.@JsonRs485Indexconfig[$entry].Parameterkey 2>/dev/null)

    # Lookup Key number from Key config block
    key_line=$(grep -A 100 "config JsonRs485Keyconfig" "$output_config_file" | grep -E "option Key[0-9]+ '$modbus_param'")
    
    if [ -n "$key_line" ]; then
        key_number=$(echo "$key_line" | awk '{print $2}' | sed 's/Key//')
        value=$(echo "$local_values" | cut -d',' -f"$((key_number + 1))")
        [ -z "$value" ] && value="null"
    else
        value="null"
    fi

    # Write to JsonKeyParametersIndex.cfg
    echo "$modbus_param" >> "$index_output_file"

    # Write to JsonKeyParameters.cfg
    echo "$modbus_param=\"$value\"" >> "$mapping_output_file"
    echo "$param_key=\"$value\"" >> "$mapping_output_file"

    # Write to JSON output
    entry=$((entry + 1))
    if [ "$entry" -lt "$count" ]; then
        echo "  \"$modbus_param\":\"$value\"," >> "$OutputJSON"
    else
        echo "  \"$modbus_param\":\"$value\"" >> "$OutputJSON"
    fi
done

# Close JSON
echo "}" >> "$OutputJSON"
