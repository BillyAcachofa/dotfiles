#!/bin/bash

# Function to get list of audio devices
get_devices() {
    aplay -l | grep '^card' | while read -r line; do
        card=$(echo "$line" | grep -o 'card [0-9]*' | awk '{print $2}')
        device=$(echo "$line" | grep -o 'device [0-9]*' | awk '{print $2}')
        name=$(echo "$line" | cut -d':' -f2-)
        echo "$card $device \"$name\""
    done
}

# Test duration in seconds
duration=2

echo "Starting audio device test..."
echo "Press Ctrl+C at any time to stop"
echo "------------------------"

# Test each device
get_devices | while read -r card device name; do
    echo "Testing: Card $card, Device $device $name"
    echo "Playing test tone for $duration seconds..."

    # Run speaker-test in background and kill after duration
    echo "speaker-test -D plughw:$card,$device -t sine -f 440 &> /dev/null &"
    speaker-test -D plughw:$card,$device -t sine -f 440 &> /dev/null &
    pid=$!
    sleep $duration
    kill $pid &> /dev/null

    echo "------------------------"
    sleep 1
done

echo "Test complete!"
