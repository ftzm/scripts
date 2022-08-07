#!/usr/bin/env bash
emacsclient --create-frame \
            --socket-name 'dired' \
            --alternate-editor='' \
            --no-wait \
            --eval "(dired nil)"
