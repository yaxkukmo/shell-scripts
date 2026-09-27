#!/usr/local/bin/ksh93
# Timer for film development
#
#set -x
usage() {
	cat <<EOF
 Description: Timer for film develpment.
 Usage: $(basename $0) -m minutes [-s seconds] 
  -s seconds 	number
  -m minutes 	number
 Example: $(basename $0) -m 5 -s 40
EOF
	return
}

trap 'tput cnorm; exit' INT TERM EXIT

is_int() {
    if (( $(( $1 + 0 )) == 0 )) 2> /dev/null; then
        return 1
    fi
    return 0
}

if (( $# == 0 )); then
    usage
    exit 1
fi

mixmessage=$(printf "[Mixing time]")
endmessage=$(printf "[Near end]")

while getopts ":t:s:m:h" OPTION; do
  case $OPTION in
    h)
        usage && exit
        ;;
    s) 
        seconds=$OPTARG
        is_int $seconds
        if (( $? != 0 )); then
            usage
            print " Error: Value for -s is not a number > 0."
            exit 1
        fi
        ;;
    m) 
        minutes=$OPTARG
        is_int $minutes
        if (( $? != 0 )); then
            usage
            print " Error: Value for -m is not a number > 0."
            exit 1
        fi
        ;;
    :) usage && print " Error: Option -${OPTARG} requires an argument" && exit ;;
    ?) usage && print " Error: Invalid option -${OPTARG}" && exit ;;

    esac
done

total_development_time=$((int(${minutes:=0} * 60 + ${seconds:=0})))
start_time=$(date +%s)

tput civis #hide cursor
tput sc
while true; do
    width=$(tput cols)
    current_time=$(date +%s)
	devtime=$(( $current_time - $start_time ))

        tput rc
    if (( $devtime < $total_development_time )); then
        message="Awaiting"

        if (( $devtime % 60 < 10 )); then
            message="${mixmessage}"
        fi

        if (( $total_development_time - $devtime < 60 )); then
            message="${message} ${endmessage}"
        fi
        remaining_minutes=$(( ($total_development_time - $devtime) / 60 ))
        remaining_seconds=$(( ($total_development_time - $devtime) % 60 ))

        line=$(printf '─%.0s' $(seq 1 $((width-2))))
        frame=""
        frame="${frame}┌${line}┐\n"
        frame="${frame}│$(printf '%-*s' $(( width-2 )) "Status: ${message}")│\n" 
        frame="${frame}│$(printf '%-*s' $(( width-2 )) "Remaining time ${remaining_minutes}:${remaining_seconds}")│\n" 
        frame="${frame}└${line}┘\n"
        printf "${frame}"
    fi
    if (( $total_development_time - $devtime <= 0 )); then
        tput cnorm
        exit
    fi

    sleep 0.5
    tput el
done
tput cnorm
