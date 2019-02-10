#!/usr/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/matt/.Xauthority

set -e
MONITOR='DP3-1'

function wait_for_monitor {
    xrandr | grep $MONITOR | grep '\bconnected'
    while [ $? -ne 0 ]; do
	logger -t "waiting for 100ms"
	sleep 0.1
	xrandr | grep $MONITOR | grep '\bconnected'
    done
}

EXTERNAL_MONITOR_STATUS=$(cat /sys/class/drm/card0-$MONITOR/status )
if [ $EXTERNAL_MONITOR_STATUS  == "connected" ]; then
    wait_for_monitor
    xrandr --output eDP1 --auto --output $MONITOR --auto --left-of eDP1
else
    xrandr --output $MONITOR --off
fi
