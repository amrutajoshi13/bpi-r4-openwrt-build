#!/bin/sh

rm -f /root/dhcp_neighbors.json
sleep 1
rm -f /www/dhcp_neighbors.json
sleep 1
touch /root/dhcp_neighbors.json
sleep 1
chmod 777 /root/dhcp_neighbors.json

# ===== DHCP Leases =====
leases_json=""
if [ -f /tmp/dhcp.leases ] && [ -s /tmp/dhcp.leases ]; then
 leases_json=$(awk '{
    cmd = "date -d @" $1 " \"+%Y-%m-%d %H:%M:%S\""
    cmd | getline human_time
    close(cmd)

    printf("{\"mac\":\"%s\",\"client_id\":\"%s\",\"client_name\":\"%s\",\"ip\":\"%s\",\"expiry\":\"%s\"},",
      $2,$5,$4,$3,human_time)
  }' /tmp/dhcp.leases | sed 's/,$//')
else
  leases_json='{"mac":"NA","client_id":"NA","client_name":"NA","ip":"NA","expiry":"NA"}'
fi
leases_json="[$leases_json]"

# ===== Neighbors (raw) =====
neighbors_json=""
neighbors_out=$(ip neigh 2>/dev/null)

if [ -n "$neighbors_out" ]; then
  neighbors_json=$(echo "$neighbors_out" | awk '{
    printf("{\"mac\":\"%s\",\"state\":\"%s\",\"interface\":\"%s\",\"ip\":\"%s\"},",$5,$6,$3,$1)
  }' | sed 's/,$//')
else
  neighbors_json='{"mac":"NA","state":"NA","interface":"NA","ip":"NA"}'
fi
neighbors_json="[$neighbors_json]"

# ===== Split neighbors into IPv4 and IPv6 using jq =====
cat <<EOF | jq '
  {
    dhcp_leases: .dhcp_leases,
    ipv4_neighbors: [.neighbors[] | select(.ip | contains("."))],
    ipv6_neighbors: [.neighbors[] | select(.ip | contains(":"))]
  }
' > /root/dhcp_neighbors.json
{
  "dhcp_leases": $leases_json,
  "neighbors": $neighbors_json
}
EOF


cp /root/dhcp_neighbors.json /www/
chmod 777  /www/dhcp_neighbors.json
