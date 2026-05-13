#!/bin/ksh

if [[ ! -z ${1} ]]; then
    cd $1
fi
print "Current directory: ${PWD}. Are you sure you want to rename files?"
read -N 1 REPLY
print ""
if [[ $REPLY == [Yy] ]]; then
    for i in *; do
        if [[ ${i} == *" "* ]]; then
            mv "${i}" "${i// /_}"
        fi
    done
fi
