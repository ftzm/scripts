prefix="m"

#use title length if passed as argument
title_length=$1
if [ -z $title_length ]; then
    title_length=1000
fi

function scroll  {
    title="$1 "
    total=${#title}
    #length=$2
    length=$title_length
    cutoff=$(( total - length + 1 ))
    start=0
    buffer=0
    while :; do
        printf '%s%s [%s%s]\n' "$prefix" "$2" "${title:$start:$length}" "${title:0:$buffer}"
        start=$((start + 1 ))
        if [ "$buffer" -ne "0" ]; then
            buffer=$(( buffer + 1 ))
        fi
        if [ "$start" -eq "$cutoff" ]; then
            buffer=1
        elif [ "$start" -eq "$total" ] ; then
            start=0
            buffer=0
        fi
        sleep 1
    done &
}

function create_line {
    IFS=$'\n'
    info=(`mpc`)
    if [ -z "${info[1]}" ]; then
        printf '%s%s\n' "$prefix" "Empty Playlist"
        return
    fi
    title=${info[0]}
    states="${info[1]} ${info[2]}"
    IFS=" "
    sa=($states)
    states="${sa[0]} ${sa[2]} ${sa[3]} ${sa[5]}"
    IFS=$'\n'
    if [ "${#title}" -gt "$title_length" ]; then
        scrolling=1
        scroll $title $states
    else
        line="$title $states"
        printf '%s%s [%s]\n' $prefix $states $title
    fi
}

while :; do
    create_line
    scroll_pid=$!
    if ! mpc idle &>/dev/null; then
        sleep 5
    fi
    if [ "$scrolling" = "1" ]; then
        kill $scroll_pid &>/dev/null
        scrolling=0
    fi
done

exit 0
