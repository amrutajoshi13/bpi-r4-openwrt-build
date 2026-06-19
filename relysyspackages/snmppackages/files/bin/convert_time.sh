#!/bin/sh

# Input: time in seconds
input_seconds=$(cat /proc/uptime |awk '{print $1}')

# Calculate time components
years=$(awk -v sec="$input_seconds" 'BEGIN {printf "%d", sec / 31536000}')
remaining_sec=$(awk -v sec="$input_seconds" -v years="$years" 'BEGIN {sec - (years * 31536000); printf "%d", sec}')

months=$(awk -v sec="$remaining_sec" 'BEGIN {printf "%d", sec / 2592000}')
remaining_sec=$(awk -v sec="$remaining_sec" -v months="$months" 'BEGIN {sec - (months * 2592000); printf "%d", sec}')

days=$(awk -v sec="$remaining_sec" 'BEGIN {printf "%d", sec / 86400}')
remaining_sec=$(awk -v sec="$remaining_sec" -v days="$days" 'BEGIN {sec - (days * 86400); printf "%d", sec}')

hours=$(awk -v sec="$remaining_sec" 'BEGIN {printf "%d", sec / 3600}')
remaining_sec=$(awk -v sec="$remaining_sec" -v hours="$hours" 'BEGIN {sec - (hours * 3600); printf "%d", sec}')

minutes=$(awk -v sec="$remaining_sec" 'BEGIN {printf "%d", (sec % 3600) / 60}')
seconds=$(awk -v sec="$remaining_sec" 'BEGIN {printf "%d", sec % 60}')

# Print the result based on available values
output=""
if [ "$years" -gt 0 ]; then
    output="${years} years"
fi
if [ "$months" -gt 0 ]; then
    if [ -n "$output" ]; then output="$output, "; fi
    output="${output}${months} months"
fi
if [ "$days" -gt 0 ]; then
    if [ -n "$output" ]; then output="$output, "; fi
    output="${output}${days} days"
fi
if [ "$hours" -gt 0 ]; then
    if [ -n "$output" ]; then output="$output, "; fi
    output="${output}${hours} hours"
fi
if [ "$minutes" -gt 0 ]; then
    if [ -n "$output" ]; then output="$output, "; fi
    output="${output}${minutes} minutes"
fi
if [ "$seconds" -gt 0 ]; then
    if [ -n "$output" ]; then output="$output, "; fi
    output="${output}${seconds} seconds"
fi

# Print the final output
echo "$output" > /tmp/convert_time
