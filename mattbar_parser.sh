#!/bin/bash

#define colors
bg="#002B36"
fg="#93A1A1"
yellow="#B58900"
orange="#CB4B16"
red="#DC322F"
magenta="#D33682"
violet="#6C71C4"
blue="#268BD2"
cyan="#2AA198"
green="#859900"


while read -r line ; do
	case $line in
        m*)
            mpd=${line#?}
            mpd=($mpd)
            title_bracks="${mpd[@]:4}"
            title=${title_bracks:1:-1}
            if [ "${mpd[0]}" = "[playing]" ]; then
                icon="⮓"
            else
                icon="⮔"
            fi
            mus="%{B$blue}%{F$bg} $icon %{F-}%{B-} $title  "
            ;;
		N*)
			if [ "${line#?}" == 0 ]; then
				status="Not Connected"
			else
				IFS=':' read -a netarr <<< "${line#?}"
				status="${netarr[0]} - ${netarr[1]}"
			fi
			net="%{A:nmcli_dmenu:}%{B$blue}%{F$bg} ⮷ %{F-}%{B-} $status %{A}"
			;;
		B*)
			bstat=${line#?}
			plug=${bstat:0:1}
			perc=${bstat:1}
			bat="%{B$blue}%{F$bg}  ${perc} %{F-}%{B-}"
			;;
		V*)
			vol="%{B$blue}%{F$bg} ⮟ ${line#?} %{F-}%{B-}"
			;;
		S*)
			clock="%{B$blue}%{F$bg}  ${line#?} %{F-}%{B-}"
			;;
		K*)
			kb=" %{B$blue}%{F$bg} ⮣ ${line#?} "
			;;
		C*)
			set -- ${line#?}
			procs=""
			while [[ $# > 1 ]]; do
				procs="$procs$1%% $2  "
				shift 2
			done
			if [[ $procs == "" ]]; then
				cpu=""
            else
				cpu="%{B$green}%{F$bg}  %{F-}%{B-}  $procs"
			fi
			;;

		M*)
			set -- ${line#?}
			procs=""
			while [[ $# > 1 ]]; do
				procs="$procs$1%% $2  "
				shift 2
			done
			if [[ $procs == "" ]]; then
				mem=""
			else
				mem="%{B$cyan}%{F$bg}  %{F-}%{B-}  $procs"
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
				ws="%{B$wsbg}%{F$wsfg} ${name} %{B-}%{F-}"
				#add workspace to growing workspaces string
				wss="$wss$ws"
			done
			;;
        *)
            xmonad=$line


	esac

	# print all statusbar components together
	printf "%s\n" "%{l}$xmonad${wss}%{r}$cpu$mem$mus$net$kb$vol$bat$clock"
done