#!/bin/bash

IOSTAT="/usr/bin/iostat"
STDBUF="/usr/bin/stdbuf"
INTERVAL=5
FACILITY="local5"
SEVERITY="info"
TAG="iostat-stats"
TAG_DEV="iostat-stats-dev"
TAG_CPU="iostat-stats-cpu"
SOCKET="/var/run/rsyslogd/iostat-stats.sock"
MATCH_DEV="^\{\"device\"\:\"sd[a-z].*"
MATCH_CPU="^\{\"avg\_cpu\"\:.*"

exec 3< <($STDBUF -oL $IOSTAT -xy $INTERVAL | $STDBUF -oL awk '
/^avg\-cpu:\s+%/ {
        gsub("%", "")
        gsub("/", "_")
        gsub("-", "_")
        gsub("%", "")
        gsub(":", "")
        split(tolower($0), FIELDS_CPU)
}
/^\s+[0-9]+\.[0-9]+/ {
        printf "{"
        for (II=1; II<=NF; ++II) {
                printf "\"" FIELDS_CPU[II] "\":\"" $II "\""
                if (II != NF) {printf ","}
        }
        printf "}\n"
}
/^Device/ {
        gsub(":", "")
        gsub("/", "_")
        gsub("-", "_")
        gsub("%", "")
        split(tolower($0), FIELDS)
}
/^[a-z0-9\-_]+\s+/ {
        printf "{"
        for (II=1; II<=NF; ++II) {
                printf "\"" FIELDS[II] "\":\"" $II "\""
                if (II != NF) {printf ","}
        }
        printf "}\n"
}')
while read line; do
if [[ $line =~ $MATCH_DEV ]];
then
        logger -e -p "$FACILITY.$SEVERITY" -t "${TAG_DEV}" --socket "$SOCKET" "$line"
fi
if [[ $line =~ $MATCH_CPU ]];
then
        logger -e -p "$FACILITY.$SEVERITY" -t "${TAG_CPU}" --socket "$SOCKET" "$line"
fi
done <&3