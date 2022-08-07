#! /usr/bin/env bash
swaymsg -t subscribe -m "[\"workspace\"]" | while read line; do echo "S;$(swaymsg -t get_workspaces -r | jq 'map( {(.name): .focused} ) | add' -c)" > /tmp/statuspipe.fifo; done
