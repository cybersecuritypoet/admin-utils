#!/bin/bash
exec 3< <(iostat -dxy 5 | awk '
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
	logger -e -p "local5.info" -t "iostat-stats" --socket "/var/run/rsyslogd/iostat-stats.sock" "$line"
done <&3
