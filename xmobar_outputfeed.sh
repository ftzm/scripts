#!/bin/bash
while read line; do
    echo "${line}" > $PANEL_FIFO
done
