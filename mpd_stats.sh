set -f
IFS='
'
lines=(`mpc`)
line1=${lines[0]}
line2=${lines[1]}
IFS=' '
line2_array=( $line2 )
playing_status=${line2_array[0]}
echo "$playing_status $line1"
set +f
