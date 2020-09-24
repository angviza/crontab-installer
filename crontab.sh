#!/bin/sh

usage () {
    cat <<USAGE_END
Usage:
    $0 add "job-spec"
    $0 list
    $0 remove "job-spec-lineno"
USAGE_END
}

if [ -z "$1" ]; then
    usage >&2
    exit 1
fi

case "$1" in
    add)
        if [ -z "$2" ]; then
            usage >&2
            exit 1
        fi

        id=`echo -n $2 | md5sum | awk '{printf "#%s#",$1}'`
        grep -w "$id" /var/spool/cron/*
        if [ $? -eq 0 ]; then
            echo "$2 already exists"
            exit 1
        fi


        tmpfile=$(mktemp)


        crontab -l >"$tmpfile"
        printf '%s\n' "$2 ${id}" >>"$tmpfile"
        crontab "$tmpfile" && rm -f "$tmpfile"
        ;;
    list)
        crontab -l | cat -n
        ;;
    remove)
        if [ -z "$2" ]; then
            usage >&2
            exit 1
        fi

        tmpfile=$(mktemp)

        id=`echo -n $2 | md5sum | awk '{printf "#%s#",$1}'`

        crontab -l | sed -e "/${id}/d" >"$tmpfile"
        crontab "$tmpfile" && rm -f "$tmpfile"
        ;;
    *)
        usage >&2
        exit 1
esac
