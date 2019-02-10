#!/bin/bash
if [ -t 0 ]; then
    emacsclient -t -a '' $*
else
    emacsclient -c -n -a '' $*
fi
