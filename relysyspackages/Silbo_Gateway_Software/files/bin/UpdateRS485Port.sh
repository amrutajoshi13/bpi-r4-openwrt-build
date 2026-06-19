CE_CFG="/root/EnergyMeterAppComponent/etc/Config/DeviceConfig.cfg"
UTILITY_CFG="/root/RS485UtilityComponent/etc/Config/RS485utilityConfig.cfg"
GENERIC_CFG="/root/EnergyMeterAppComponent/etc/Config/GenericFile.cfg"

# Read board ID from flash offset 0xF020
flash_val_f020=$(dd if=/dev/mtd2 bs=1 skip=$((0xF020)) count=1 2>/dev/null | hexdump -v -e '1/1 "%02X"')
# Read board subtype from flash offset 0xF021
flash_val_f021=$(dd if=/dev/mtd2 bs=1 skip=$((0xF021)) count=1 2>/dev/null | hexdump -v -e '1/1 "%u"')

# Default values
[ -z "$flash_val_f020" ] && flash_val_f020="FF"
[ -z "$flash_val_f021" ] && flash_val_f021="255"

# Decide board name
case "$flash_val_f020" in
    0B) board_name="IDB54-C-GW" ;;
    0F) board_name="IDF54-C-GW" ;;
    47)
        case "$flash_val_f021" in
            88) board_name="silbo-IDG50-GW" ;;
            99) board_name="silbo-RVWG50-GW" ;;
             *) board_name="silbo-RVWG50-GW" ;;
        esac
        ;;
     *) board_name=$(cat /tmp/sysinfo/board_name) ;;
esac
echo "Detected Board Name : $board_name"

# Read No_of_Serial_Ports from GenericFile.cfg
NUM_PORTS=1
if [ -f "$GENERIC_CFG" ]; then
    cfg_ports=$(grep -m1 '^No_of_Serial_Ports=' "$GENERIC_CFG" | cut -d'=' -f2 | tr -d ' \r')
    if echo "$cfg_ports" | grep -qE '^[0-9]+$'; then
        NUM_PORTS=$cfg_ports
    fi
fi
echo "No. of Serial Ports (from cfg) : $NUM_PORTS"

# Decide serial port 1 and whether board is IDG/RVWG
if echo "$board_name" | grep -qE "(IDG|RVWG)"; then
    SERIAL_PORT="/dev/ttyUSB0"
    IS_IDG_RVWG=1
else
    SERIAL_PORT="/dev/ttyS1"
    IS_IDG_RVWG=0
fi

echo "Updating SerialPort_1 : $SERIAL_PORT"

########################################
# Detect 2nd and 3rd ports via sysfs
# Only when: NUM_PORTS >= 2 AND not IDG|RVWG
########################################
SERIAL_PORT_2=""
SERIAL_PORT_3=""

if [ "$NUM_PORTS" -ge 2 ] && [ "$IS_IDG_RVWG" -eq 0 ]; then
    echo "Detecting USB serial ports with ch341 driver ..."

    ch341_ttys=""

    # Primary: walk sysfs ch341 driver bindings
    if [ -d /sys/bus/usb/drivers/ch341 ]; then
        for iface in /sys/bus/usb/drivers/ch341/*; do
            [ -L "$iface" ] || continue
            tty_name=$(find "$iface" -maxdepth 3 -name 'ttyUSB*' 2>/dev/null | head -n1)
            if [ -n "$tty_name" ]; then
                ch341_ttys="$ch341_ttys $(basename "$tty_name")"
            fi
        done
    fi

    # Fallback: parse lsusb -t, match Dev numbers via sysfs devnum
    if [ -z "$ch341_ttys" ]; then
        echo "sysfs ch341 walk found nothing, falling back to lsusb -t ..."
        lsusb -t 2>/dev/null | grep "Driver=ch341" | while read -r line; do
            dev_num=$(echo "$line" | sed -n 's/.*Dev \([0-9]*\).*/\1/p')
            [ -z "$dev_num" ] && continue
            for dev_path in /sys/bus/usb/devices/*/; do
                [ -f "$dev_path/devnum" ] || continue
                if [ "$(cat "$dev_path/devnum")" = "$dev_num" ]; then
                    tty_name=$(find "$dev_path" -maxdepth 4 -name 'ttyUSB*' 2>/dev/null | head -n1)
                    [ -n "$tty_name" ] && echo "$(basename "$tty_name")"
                fi
            done
        done > /tmp/_ch341_ttys.txt
        ch341_ttys=$(cat /tmp/_ch341_ttys.txt 2>/dev/null | tr '\n' ' ')
        rm -f /tmp/_ch341_ttys.txt
    fi

    # Sort numerically: ttyUSB0 < ttyUSB1 < ttyUSB2 ...
    ch341_ttys_sorted=$(echo "$ch341_ttys" | tr ' ' '\n' | grep -v '^$' | sort -t 'B' -k2 -n | tr '\n' ' ')
    echo "ch341 devices found (sorted): $ch341_ttys_sorted"

    # Assign port 2 (and port 3 if needed) from sorted list
    port_idx=0
    for tty in $ch341_ttys_sorted; do
        port_idx=$((port_idx + 1))
        if [ "$port_idx" -eq 1 ]; then
            SERIAL_PORT_2="/dev/$tty"
            echo "Assigning SerialPort_2 : $SERIAL_PORT_2"
        elif [ "$port_idx" -eq 2 ] && [ "$NUM_PORTS" -ge 3 ]; then
            SERIAL_PORT_3="/dev/$tty"
            echo "Assigning SerialPort_3 : $SERIAL_PORT_3"
            break
        fi
    done

    [ -z "$SERIAL_PORT_2" ] && echo "WARNING: No ch341 device found for SerialPort_2"
    [ "$NUM_PORTS" -ge 3 ] && [ -z "$SERIAL_PORT_3" ] && echo "WARNING: Only one ch341 device found; SerialPort_3 will not be updated"
fi

############################
# Update Utility Config    #
############################
if [ -f "$UTILITY_CFG" ]; then
    sed -i "s|^SerialPort=\".*\"|SerialPort=\"$SERIAL_PORT\"|g" "$UTILITY_CFG"
    echo "Updated $UTILITY_CFG"
fi

############################
# Update GenericFile.cfg   #
# Only SerialPort_N lines  #
############################
if [ -f "$GENERIC_CFG" ]; then
    tmp_file="/tmp/GenericFile.tmp"
    while IFS= read -r line; do
        case "$line" in
            SerialPort_1=*)
                printf 'SerialPort_1="%s"\n' "$SERIAL_PORT"
                ;;
            SerialPort_2=*)
                if [ -n "$SERIAL_PORT_2" ]; then
                    printf 'SerialPort_2="%s"\n' "$SERIAL_PORT_2"
                else
                    printf '%s\n' "$line"    # leave unchanged if not detected
                fi
                ;;
            SerialPort_3=*)
                if [ -n "$SERIAL_PORT_3" ]; then
                    printf 'SerialPort_3="%s"\n' "$SERIAL_PORT_3"
                else
                    printf '%s\n' "$line"    # leave unchanged if not detected
                fi
                ;;
            *)
                printf '%s\n' "$line"        # all other lines untouched
                ;;
        esac
    done < "$GENERIC_CFG" > "$tmp_file"
    mv "$tmp_file" "$GENERIC_CFG"
    echo "Updated $GENERIC_CFG (SerialPort entries only)"
fi

echo "Serial port update completed."
exit 0
