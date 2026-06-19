#!/bin/sh

rm -f /root/interface.json
sleep 1
touch /root/interface.json
chmod 777 /root/interface.json

dev_json="$(ubus call network.device status)"
iface_json="$(ubus call network.interface dump)"

echo "$iface_json" | jq --argjson dev "$dev_json" '

  ####################################################################
  # 1) BUILD INTERFACE LOOKUP MAP: device_name → proto, ipv4_address
  #    Only pick entries that actually contain IPv4 address.
  #    This avoids usb0 being overwritten by wan6c1 (IPv6-only).
  ####################################################################
  (.interface // []
   | map(
       select(.["ipv4-address"] != null and .["ipv4-address"][0].address != null)
       | {
           (.l3_device // .device): {
             proto: (.proto // "none"),
             ipv4_address: .["ipv4-address"][0].address
           }
         }
     )
   | add
  ) as $ifmap

  ####################################################################
  # 2) MERGE DEVICE STATUS + INTERFACE LOOKUP
  ####################################################################
  | ($dev | to_entries | map(
      . as $e
      | {
          key: $e.key,
          value: {
            type: $e.value.type,
            ipv4_address: ($ifmap[$e.key].ipv4_address // "NA"),
            proto: ($ifmap[$e.key].proto // "none"),
            up: $e.value.up,
            mtu: $e.value.mtu,
            macaddr: $e.value.macaddr,
            txqueuelen: $e.value.txqueuelen,
            multicast: $e.value.multicast,
            statistics: {
              rx_bytes: $e.value.statistics.rx_bytes,
              rx_packets: $e.value.statistics.rx_packets,
              tx_packets: $e.value.statistics.tx_packets,
              tx_bytes: $e.value.statistics.tx_bytes
            }
          }
        }
    ) | from_entries)

' > /root/interface.json

