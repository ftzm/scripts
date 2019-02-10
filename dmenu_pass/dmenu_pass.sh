#!/usr/bin/env bash

#account=$(find ~/.password-store -not -path '*/\.*' -type f | cut -c17- | sed 's/....$//' | dmenu)
passes=$(find ~/.password-store -not -path '*/\.*' -type f)
echo $passes
if [[ ${#account} -ge 3 ]]; then
    xdotool type $(pass ${account})
    xdotool key Return
fi
