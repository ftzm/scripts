#!/bin/sh

iwconfig wlp3s0 2>&1 | grep -q no\ wireless\ extensions\. && {
  echo wired
  exit 0
}

essid=`iwconfig wlp3s0 | awk -F '"' '/ESSID/ {print $2}'`
strength=`iwconfig wlp3s0 | awk -F '=' '/Quality/ {print $2}' | cut -d '/' -f 1`

echo "$essid $strength"
