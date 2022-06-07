#! /bin/bash
# Publish wemo smartplug data to my influx server.

host="http://192.168.1.154:8086/write?db=grafana"
home_assistant="http://192.168.4.60:8123/api/states"
global_timeout=10

# Publish metrics to my influx db on the upstream subnet.
curl -s -X GET -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJiM2ExMTA3NGVmZGU0MzA2YmI3YWFkMWRkZGVlZjQ5OSIsImlhdCI6MTU3NjU5NTQ4MywiZXhwIjoxODkxOTU1NDgzfQ.mTN_Yigtlh5xmQaQmDqn26ihguHy1ON8gPYZv2WJrDQ" -H "Content-Type: application/json" "$home_assistant" | jq -r '.[] | select(.attributes.friendly_name == "Christmas Lights" or .attributes.friendly_name == "Bedroom Lamp" or .attributes.friendly_name == "Corner Lamp") | ("home_assistant,smartplug=" + .entity_id + " value=" + (if .state == "off" then "0" else "1" end))' | while read line; do curl -i -X POST "$host" --data-binary "$line"; done
