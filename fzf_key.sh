#!/usr/bin/env bash

# clipboard doesn't work for some reason
buf=$(mktemp)
trap 'rm -f -- $buf' EXIT

foot -a foot-launcher bash -c "find .password-store -not -path '*/\.*' -type f | cut -c17- | sed 's/....$//' | fzf --margin=1,3 --color bg+:\#282828,fg+:223,hl+:\#fabd2f,info:\#504945 | xargs pass > $buf"

wl-copy -n < $buf
