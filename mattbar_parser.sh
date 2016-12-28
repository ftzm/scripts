#!/bin/bash

##define colors
#bg="#002B36"
#fg="#93A1A1"
#yellow="#B58900"
#orange="#CB4B16"
#red="#DC322F"
#magenta="#D33682"
#violet="#6C71C4"
#blue="#268BD2"
#blue1="#1E77B2"
#blue2="#166493"
#blue3="#0F5174"
#blue4="#073E55"
#cyan="#2AA198"
#green="#859900"

#define colors
bg="#002B36"
fg="#93A1A1"
yellow="#B58900"
orange="#CB4B16"
red="#cc241d"
magenta="#D33682"
violet="#6C71C4"
blue="#268BD2"
blue1="#1E77B2"
blue2="#166493"
blue3="#0F5174"
blue4="#073E55"
cyan="#2AA198"
green="#859900"

blues="$(bar_gradient $blue $bg 5)"
blues=($blues)

while read -r line ; do
	case $line in
        m*)
            mpd=${line#?}
            mpd=($mpd)
            title_bracks="${mpd[@]:4}"
            title=${title_bracks:1:-1}
            if [ "${mpd[0]}" = "[playing]" ]; then
                icon=">"
            else
                icon="||"
            fi
            mus=" $title%{-u} "
            ;;
		N*)
			if [ "${line#?}" == 0 ]; then
				#status="Not Connected"
				status="down"
			else
				IFS=':' read -a netarr <<< "${line#?}"
				#status="${netarr[0]} - ${netarr[1]}"
				status="up"
			fi
			net="%{A:nmcli_dmenu:} %{+u}%{U$red}$status%{-u} "
			;;
		B*)
			bstat=${line#?}
			plug=${bstat:0:1}
			perc=${bstat:1}
			bat=" %{+u}%{U$red}bat ${perc}%{-u} "
			;;
		V*)
			vol=" %{+u}%{U$red}vol ${line#?}%{-u} "
			;;
		S*)
			clock=" %{+u}%{U$red}${line#?}%{-u} "
			;;
		K*)
			kb=" %{+u}%{U$red}${line#?}%{-u} "
			;;
		C*)
			set -- ${line#?}
			procs=""
			while [[ $# > 1 ]]; do
				procs="$procs$1% $2  "
				shift 2
			done
			if [[ $procs == "" ]]; then
				cpu=""
            else
				cpu=" %{+u}%{U$red}$procs%{-u} "
			fi
			;;

		M*)
			set -- ${line#?}
			procs=""
			while [[ $# > 1 ]]; do
				procs="$procs$1% $2  "
				shift 2
			done
			if [[ $procs == "" ]]; then
				mem=""
			else
				mem=" %{+u}%{U$red}$procs%{-u} "
			fi
			;;
		3*)
			wss=""
			#define workspace names, automatically assigned to matching workspace number
			names=(main web dev term mus)
			#split up the string with colons
			#remove 3 character from start of line, name to spaces for for loop
			spaces=${line#?}
			#loop through each workspace
			for space in $spaces; do
				#set colors based on workspace status
				case $space in
					foc*)
						wsfg=$bg
						wsbg=$yellow
						;;
					unf*|urg*)
						wsfg=$fg
						wsbg=$bg
				esac
				#get number by removing first three chars
				num=${space#???}
				#if workspace number within range of names array, assign corresponding name from array
				if [ $[num-1] -lt ${#names[@]} ] ; then
					name="${names[num-1]}"
				else
					name="${num}"
				fi
				#put together workspace string
				ws=" ${name} "
				#add workspace to growing workspaces string
				wss="$wss$ws"
			done
			;;
        *)
            xmonad=$line


	esac

	# print all statusbar components together
	printf "%s\n" "%{l}$xmonad${wss}%{r}$mus$net$kb$vol$bat$clock"
done
