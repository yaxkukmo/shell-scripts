#!/bin/ksh
#set -x
DIR=~/.notes
SCRIPT=$(basename $0)
if [[ ! -r $DIR ]]; then
	mkdir $DIR
fi

usage() {
    cat <<EOF
    Simple notes system.

    Usage: ${SCRIPT} [-h] [-a] [-u] [-r] [-l]
        -h help
				-l list notes
        -a add new note
        -u update note
        -r remove note
EOF
}

calculateId() {
    MAX=`ls $DIR | sort -n | tail -1`
    return $(( $MAX + 1 ))
}

while getopts ":u:r:hal" OPTION; do
    case $OPTION in
        a)  calculateId
            ID=$?
            if [[ -z $ID ]]; then
                ID=1
            fi
            nvim $DIR/$ID
            exit
            ;;
        u) ID=$OPTARG 
            if [[ -f $DIR/$ID ]]; then
                nvim $DIR/$ID
            else
                print "Error: no such ID"
            fi
            exit
            ;;
        r) ID=$OPTARG 
            if [[ -f $DIR/$ID ]]; then
                rm $DIR/$ID
            else
                print "Error: no such ID"
            fi
            exit
            ;;
        l) 
            find $DIR -type f -exec basename {}" ######" \; -exec cat {} \;
            exit
            ;;
        h) usage && exit ;;
        :) print "Error: Option -${OPTARG} requires an argument" && exit ;;
        ?) print "Error: Invalid option -${OPTARG}" && exit ;;
    esac
done


