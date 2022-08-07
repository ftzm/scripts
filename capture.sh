#!/usr/bin/env bash
emacsclient --create-frame \
            --socket-name 'capture' \
            --alternate-editor='' \
            --frame-parameters='(quote (name . "capture"))' \
            --no-wait \
            --eval "(ftzm/org-capture-frame \"$1\")"
