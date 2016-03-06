#!/bin/bash

mattbar.sh &

while read line; do
    echo "${line}" > $PANEL_FIFO
done
