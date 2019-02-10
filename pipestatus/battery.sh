#!/usr/bin/env bash

while true; do
    status=$(upower -i "$(upower -e | grep '/battery')" | grep --color=never -E "state|to\\ full|to\\ empty|percentage" | tr '\n' ';')
    echo "b;$status" > /tmp/statuspipe.fifo
    sleep 300
done
