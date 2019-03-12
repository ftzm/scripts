#!/usr/bin/env bash

ID=28:11:A5:DA:8C:06

if [[ "$(bluetoothctl info | grep -c comfy)" -gt 0 ]]; then
    output=$(bluetoothctl disconnect ${ID})
    if [ -z "$(echo ${output} | grep "Successful disconnected")" ]; then
	message=$output
    else
	message="Disconnected"
    fi
else
    output=$(bluetoothctl connect ${ID})
    if [ -z "$(echo ${output} | grep "Connection successful")" ]; then
	message=$output
    else
	message="Connected"
    fi
fi

notify-send "Headphones" "${message}"
