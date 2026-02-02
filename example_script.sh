#!/bin/bash

SCRIPT_NAME=$(basename $0)

usage() {
  cat <<EOF

  Example script description.

  Usage: ${SCRIPT_NAME} [-h] [-o argument]
    -h   This text.
    -o argument   Option with argument.
EOF
}

case $# in
  0) usage
		exit
		;;
esac

while getopts ":o:h" OPTION; do
  case $OPTION in
    h)
      usage
      exit
      ;;
    o)
      OPTION_ARGUMENT=$OPTARG
      ;;
		:)
			echo "Error: Option -${OPTARG} requires an argument."
			usage
			exit 1
			;;
    ?)
      echo "Error: Invalid option -${OPTARG}"
      usage
			exit 1
      ;;
  esac
done



echo "${OPTION_ARGUMENT} here goes your code"

