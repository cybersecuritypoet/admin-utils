#!/bin/bash
IOSTAT="/usr/bin/iostat"
INTERVAL=5
FACILITY="local5"
SEVERITY="info"
TAG="iostat-stats"
SOCKET="/var/run/rsyslogd/iostat-stats.sock"
exec 3< <(iostat -dxy $INTERVAL | awk '
/^Device/ {
    gsub(":", "")
    gsub("/", "_") 
    gsub("-", "_")
    gsub("%", "")
    split(tolower($0), FIELDS)
}
/^[a-z0-9]+/ {
    printf "{"
    for (II=1; II<=NF; ++II) {
        printf "\"" FIELDS[II] "\":\"" $II "\""
		if (II != NF) {printf ","}
    }
    printf "}\n"
}')
while read line; do
	logger -e -p "$FACILITY.$SEVERITY" -t "$TAG" --socket "$SOCKET" "$line"
done <&3
