#!/bin/bash
IOSTAT="/usr/bin/iostat"
STDBUF="/usr/bin/stdbuf"
INTERVAL=5
FACILITY="local5"
SEVERITY="info"
TAG="iostat-stats"
SOCKET="/var/run/rsyslogd/iostat-stats.sock"
MATCH="^\{\"device\"\:\"sd[a,b].*"
exec 3< <($STDBUF -oL $IOSTAT -dxy $INTERVAL | $STDBUF -oL awk '
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
if [[ $line =~ $MATCH ]];
then
	logger -e -p "$FACILITY.$SEVERITY" -t "$TAG" --socket "$SOCKET" "$line"
	echo "$line"
fi
done <&3