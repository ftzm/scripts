#! /usr/bin/env bash

connected_number=$(xrandr | grep " connected " | awk '{ print$1 }' | wc -l)

if [ "$connected_number" = "2" ]; then
    xrandr --output eDP1 --auto --output DP3-1 --auto --left-of eDP1
else
    xrandr --auto
fi
