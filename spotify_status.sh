#!bin/bash

artist="$((playerctl metadata artist) 2>&1)"
title="$((playerctl metadata title) 2>&1)"
status="$((playerctl status) 2>&1)"
exit_status=$?
if [ "$exit_status" -eq "0" ]; then
    if [ "$status" = "Paused" ]; then
	symbol=""
    else
	symbol=""
    fi
    echo "$symbol $artist - $title"
fi
