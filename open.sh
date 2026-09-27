#!/usr/local/bin/ksh93
#set -x
SCRIPT_NAME=$(basename $0)

usage() {
  cat <<EOF

  Open file.

  Usage: ${SCRIPT_NAME} [-h] file
    -h   This text.
EOF
}

case $# in
    0)
        usage
        exit
        ;;
esac

while getopts ":h" OPTION; do
  case $OPTION in
    h)
        usage
        exit
        ;;
    ?)
        print "Error: Invalid option -${OPTARG}"
        usage
        exit 1
        ;;
  esac
done

shift $((OPTIND - 1))

provided_file=$1

if [[ -z $provided_file ]]; then
    print "Error: No file provided."
fi


if [[ ! -r $provided_file ]]; then
    print "Error: File does not exist."
fi

ftype_output=$(file $provided_file)
ftype="${ftype_output/${provided_file}:/}"
echo $ftype

case "${ftype}" in
    *"ASCII text")
        less $provided_file ;;
    *"text executable")
        nvim $provided_file ;;
    *"PDF document"*)
        gv $provided_file ;;
    *"EPUB document"*)
        epr $provided_file ;;
    *"image"*)
        feh $provided_file ;;
    *"SQLite"*)
        visidata $provided_file ;;
esac
