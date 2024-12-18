#!/bin/bash

PORTS=(8227 8230 8232 8234 8236 8238 8240 8242)
id=1
peer_ids=()

for PORT in "${PORTS[@]}"; do
  response=$(curl -s -X POST http://127.0.0.1:"$PORT" \
    -H "Content-Type: application/json" \
    -d "$(printf '{
                 "id": %d,
                 "jsonrpc": "2.0",
                 "method": "node_info",
                 "params": []
             }' "$id")")
  if [ $? -eq 0 ]; then
    peer_id=$(echo "$response" | jq -r '.result.peer_id')
    echo "$peer_id"
    peer_ids+=("$peer_id")
  else
    echo "Query to port $PORT failed."
  fi

  ((id++))
done

#for peer_id in "${peer_ids[@]}"; do
#  echo "$peer_id"
#done

f_peer_id="${peer_ids[5]}"
g_peer_id="${peer_ids[6]}"

for i in 0 1 2 3 4 6; do
  port="${PORTS[i]}"

  list_channels_json_data=$(
    cat <<EOF
{
  "id": $(($i + 1)),
  "jsonrpc": "2.0",
  "method": "list_channels",
  "params": [
    {
      "peer_id": "$f_peer_id"
    }
  ]
}
EOF
  )

  curl -sS --location "http://127.0.0.1:$port" --header "Content-Type: application/json" --data "$list_channels_json_data" | jq -r
done
echo ""

for i in 5 7; do
  port="${PORTS[i]}"

  list_channels_json_data=$(
    cat <<EOF
{
  "id": $(($i + 1)),
  "jsonrpc": "2.0",
  "method": "list_channels",
  "params": [
    {
      "peer_id": "$g_peer_id"
    }
  ]
}
EOF
  )

  curl -sS --location "http://127.0.0.1:$port" --header "Content-Type: application/json" --data "$list_channels_json_data" | jq -r
done
