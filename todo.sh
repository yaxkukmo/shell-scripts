#!/bin/ksh

DATABASE=$HOME/projects/todo.db
SCRIPT_NAME=$(basename $0)
#set -x
usage() {
    cat <<EOF

  Simple "TODO" system.

  Usage: ${SCRIPT_NAME} [-h|s] [[-t tag] -j description -w date] 
    -h   This text.
    -s                  Show todo list.
    -j description      Job to do.
    -w date             Job date.

  Examples:
    ${SCRIPT_NAME} -s                                               #Show todo list.
    ${SCRIPT_NAME} -t "work"                                        #Add new tag.
    ${SCRIPT_NAME} -j "Doctor appointment" -w 23-12-2026            #Add new item
    ${SCRIPT_NAME} -j "Doctor appointment" -w 28-02-2026 -t work    #Add new item with tag
EOF
}

create() {
    if [[ ! -f $DATABASE ]]; then
        print "Database doesn't exist. Creating new one."

        sqlite3 $DATABASE "PRAGMA foreign_keys = on;
        CREATE TABLE todo(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            job TEXT NOT NULL,
            job_time DATETIME,
            tag_id INTEGER,
            created_at DATETIME DEFAULT current_timestamp,
            FOREIGN KEY(tag_id) REFERENCES TAG(id)
        );

        CREATE TABLE tag(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
        );
        INSERT INTO tag (name) VALUES ('default');
        "
        if (( $? == 0 )); then
            print "Database created successfuly."
        else
            print "Error: Creating database failed." >&2
            rm $DATABASE;
            exit;
        fi
    fi
}

is_valid_optarg() {
    if [[ $1 == -* ]]; then
        return 1
    fi
    return 0
}

is_valid_date() {
    DAY=$(print $1 | awk -F "-" '{ print $1 }')
    MONTH=$(print $1 | awk -F "-" '{ print $2 }')
    YEAR=$(print $1 | awk -F "-" '{ print $3 }')

    if [[ $(date "+%d-%m-%Y" -d ${YEAR}-${MONTH}-${DAY} 2>/dev/null) == $1 ]]; then
        return 0
    fi
    return 1
}

case $# in
    0) usage
	    exit
	    ;;
esac

while getopts ":j:w:t:hs" OPTION; do
  case $OPTION in
    s)
        create
        sqlite3 $DATABASE ".headers on" ".mode column" "select job as 'To do', strftime('%d-%m-%Y', job_time) as 'Date', tag.name as 'Category' from todo join tag on todo.tag_id= tag.id where todo.job_time >= date('now') ORDER BY job_time"
        exit;
        ;;
    h)
        usage
        exit
        ;;
    t)
        create

        if [[ -z ${OPTARG##[[:space:]]} ]]; then
            print "Error: Option -t requires an argument." >&2
            usage
            exit 1
        fi

        is_valid_optarg $OPTARG
        if (( $? > 0 )); then
            print "Error: OPTARG begins with '-' character. Did you forget about -t argument?" >&2
            exit 1
        fi

        TAG_ID=$(sqlite3 $DATABASE "select id from tag where name='${OPTARG}'")

        if [[ -z $TAG_ID ]]; then

            sqlite3 $DATABASE "INSERT INTO tag (name) VALUES ('${OPTARG}')"

            if (( $? == 0 )); then
                print "Tag added."
            else
                print "Error: Tag cannot be added." >&2
                exit 1
            fi
        fi
        ;;
    j)
        create

        if [[ -z ${OPTARG##[[:space:]]} ]]; then
            print "Error: Option -j requires an argument." >&2
            usage
            exit 1
        fi

        is_valid_optarg $OPTARG
        if (( $? > 0 )); then
            print "Error: OPTARG begins with '-' character. Did you forget about -j argument?" >&2
            exit 1
        fi
        JOB=$OPTARG
        ;;

    w)
        create

        if [[ -z ${OPTARG##[[:space:]]} ]]; then
            print "Error: Option -w requires an argument." >&2
            usage
            exit 1
        fi

        is_valid_optarg $OPTARG
        if (( $? > 0 )); then
            print "Error: OPTARG begins with '-' character. Did you forget about -w argument?" >&2
            exit 1
        fi

        is_valid_date $OPTARG
        if (( $? > 0 )); then
            print "Error: Date is not in d-m-Y format" >&2
            exit 1
        fi

        DAY=$(print $OPTARG | awk -F "-" '{ print $1 }')
        MONTH=$(print $OPTARG | awk -F "-" '{ print $2 }')
        YEAR=$(print $OPTARG | awk -F "-" '{ print $3 }')
        WHEN="${YEAR}-${MONTH}-${DAY}"
        ;;
    :)
		print "Error: Option -${OPTARG} requires an argument." >&2
		usage
		exit 1
		;;
    ?)
        print "Error: Invalid option -${OPTARG}" >&2
        usage
		exit 1
      ;;
  esac
done

if [[ -z ${JOB+x} ]] && [[ -z ${WHEN+x} ]]; then
    print "No items to add" >&2
fi
sqlite3 $DATABASE "INSERT INTO todo (job, job_time, tag_id) values ('${JOB}',  date('${WHEN}'), ${TAG_ID:=1})"

if (( $? == 0 )); then
    print "New TODO item added."
else
    print "Error: Cannot add new TODO item." >&2
    exit 1
fi
