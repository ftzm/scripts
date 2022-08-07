#!/usr/bin/env bash

set eu

#defaults
metric="3,3" # measure cpu
percent="3"
number="3"
cutoff=0
length=20

while [[ $# > 0 ]]; do
	key="$1"
	case $key in
		-m|--memory)
			metric="4,4" # measure memory
			percent="4"
			shift
			;;
		-n|--number)
			number=$2
			shift
			;;
		-c|--cutoff)
			cutoff=$2
			shift
			;;
		-l|--length)
			length=$2
			shift
			;;
		*)
			shift
			;;
	esac
done

procs=`ps aux | tail -n +2 | sort -n -rk $metric | head -n $number | awk -v \
    perccol=$percent '{print $perccol" "substr($0, index($0,$11))}'`

IFS=$'\n'

if [ $cutoff != 0 ]; then
	remaining_procs=''
	for p in $procs; do
	IFS=" "
		set -- $p
		if (( $(bc <<< "$1 > $cutoff") )); then
			remaining_procs+=$(printf '\n%s' "$p")
		fi
	IFS=$'\n'
	done
	procs=$remaining_procs
fi

line=""
for p in $procs; do

	IFS=" "
	set -- $p
	name2=""

	percent=$1
	shift

	if [[ $1 == /* ]];  then
		if [[ $1 == *bin || $1 == *python ]]; then
			shift
			while [[ $# > 0 ]]; do
				if [[ $1 != -* ]]; then
					IFS="/"
					dir=( $1 )
					name1="${dir[-1]}"
					IFS=" "
					break
				fi
				shift
			done
		elif [[ ${2-} == /* ]]; then
			IFS="/"
			dir=( $2 )
			name1=${dir[-1]}
			IFS=" "
		else
			IFS="/"
			dir=( $1 )
			name1=${dir[-1]}
			IFS=" "
		fi
	else
		name1=$1
		shift
		while [[ $# > 0 ]]; do
			if [[ $1 != -* ]]; then
				IFS="/"
				dir=( $1 )
				name2="-${dir[-1]}"
				IFS=" "
				break
			fi
			shift
		done

	fi

    name="$name1$name2"
	line="$line $percent ${name:0:$length}"
done
printf "%s\n" "$line"
