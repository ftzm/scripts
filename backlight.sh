#!/usr/bin/env bash

BRIGHTNESS=$(xbacklight| awk '{ val = $1}; END { print int(val) }')

echo $BRIGHTNESS

exit 0
