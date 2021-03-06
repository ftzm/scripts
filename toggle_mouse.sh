#!/usr/bin/env bash

declare -i ID
ID=`xinput list | grep -Eio 'touchpad\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}'`
echo $ID
declare -i STATE
STATE=`xinput list-props $ID|grep 'Device Enabled'|awk '{print $4}'`
if [ $STATE -eq 1 ]
then
    xinput disable $ID
    xdotool mousemove 10000 10000
else
    xinput enable $ID
    line=`xrandr | head -1`
    set -- $line
    shift 7
    width=$1
    height=${3%?}
    halfwidth=`expr $width / 2`
    halfheight=`expr $height / 2`
    xdotool mousemove $halfwidth $halfheight
fi
