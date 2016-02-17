#!/bin/bash

#PANEL_FIFO="/tmp/i3_lemonbar_${USER}"
#fifo defined in bash profile so that distributed scripts can pipe to it with ease

font="-*-lemon-medium-r-normal-*-10-*-*-*-m-*-*-1"
iconfont="-Misc-Stlarch-Medium-R-Normal--10-100-75-75-C-80-ISO10646-1"
fg="#93a1a1"
bg="#002B36"

# remove fifo if exists and create new
[ -e "${PANEL_FIFO}" ] && rm "${PANEL_FIFO}"
mkfifo "${PANEL_FIFO}"

# script to feed workspace info to fifo on change
python -u $(dirname $0)/myi3.py > "$PANEL_FIFO" &

# clock feed
clock -sf 'S%H.%M' > "$PANEL_FIFO" &

# battery feed
# only runs once here, use cron for updates
/home/matt/bin/battery_man &

# music feed
$(dirname $0)/mpc_grab.sh 30 > "$PANEL_FIFO" &

# network feed
device=`find /sys/class/net -name "w*" | xargs basename`
(while :; do wifi_stats $device; sleep 60; done) &

# keyboard feed
kb=$(setxkbmap -query|awk '/layout/ {print $2}') && echo "K$kb" > "$PANEL_FIFO" &

# cpu feed
while :; do
	echo "C`$(dirname $0)/top_procs.sh -c 1.5`" > "$PANEL_FIFO"
	sleep 2
done &

# mem feed
while :; do
	echo "M`$(dirname $0)/top_procs.sh -m -c 1`" > "$PANEL_FIFO"
	sleep 2
done &

# vol  feed
vol=`amixer get Master | grep -oE "[[:digit:]]*%" | sed 's/.$//'` && echo "V$vol" > "$PANEL_FIFO" &

# pipe chain from fifo through parser to lemonbar
cat "${PANEL_FIFO}" | $(dirname $0)/mattbar_parser.sh \
	| lemonbar -g x14 -p -f "${font}" -f "${iconfont}" -F ${fg} -B ${bg} \
       | while read action; do bash -c "${action}"; done &

wait
