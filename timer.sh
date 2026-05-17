#!/bin/ksh
# Timer for film development
#
usage() {
	cat <<EOF
 Description: Timer for film develpment.
 Usage: $(basename $0) -m minutes [-s seconds] [-t type]
  -s seconds 	number
  -m minutes 	number
  -t type 	standard (10 first second of each minutes) or 
		stand (10 seconds 1st minute and then 10 seconds in half time)
 Example: $(basename $0) -m 5 -s 40 -t standard
EOF
	return
}

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

MIXMESSAGE="[\033[41m Mixing time \033[0m]"
ENDMESSAGE="[\033[41m Near end \033[0m]"

while getopts ":t:s:m:h" OPTION; do
  case $OPTION in
    h) usage && exit   ;;
		t) TYPE=$OPTARG;
			;;
		s) SECONDS=OPTARG
			is_int $SECONDS
			if (( $? != 0 )); then
				usage
				print " Error: Value for -s is not a number > 0."
				exit 1
			fi
			;;
		m) MINUTES=OPTARG
			is_int $MINUTES
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

TOTAL_DEVELOPMENT_TIME=$(( int(${MINUTES:=0} * 60 + ${SECONDS:=0}) ))
START_TIME=$(date +%s)

while true; do
	TIME=$(date +%s)
	DEVTIME=$(( $TIME - $START_TIME ))

	if (( $DEVTIME < $TOTAL_DEVELOPMENT_TIME )); then
		MESSAGE=""

		if (( $DEVTIME % 60 < 10 )); then
			MESSAGE="${MIXMESSAGE}"
		fi

		if (( $TOTAL_DEVELOPMENT_TIME - $DEVTIME < 60 )); then
			MESSAGE="${MESSAGE} ${ENDMESSAGE}"
		fi

		print "${MESSAGE} (${DEVTIME} of ${TOTAL_DEVELOPMENT_TIME})"
		tput cuu1
	fi
	if (( $TOTAL_DEVELOPMENT_TIME - $DEVTIME <= 0 )); then
		exit
	fi

	sleep 0.5
	tput el
done
