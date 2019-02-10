# return a list of all frames on $DISPLAY
emacsclient -e "(frames-on-display-list \"$DISPLAY\")" &>/dev/null

# open frames detected, so open files in current frame
if [ $? -eq 0 ]; then
    emacsclient -n -t $*
    # no open frames detected, so open new frame
else
    emacsclient -n -c $*
fi
