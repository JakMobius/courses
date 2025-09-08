#!/bin/bash

set -m

processes=8
requests=5000

command time -o server-stats.tmp -p ./a.out &
pid=$!

urls=$(seq 1 $requests | xargs -I{} echo "http://localhost:1234/")

seq 1 $processes | command time -o curl-stats.tmp -p xargs -P0 -I{} curl -s $urls > /dev/null
times=$(cat curl-stats.tmp)
seconds=$(echo "$times" | grep real | cut -d' ' -f2)
echo "Requests per second: $(bc <<< "scale=2; $requests * $processes / $seconds")"

kill -SIGINT -- -$pid
wait $pid 2> /dev/null
server_stats=$(cat './server-stats.tmp')
server_real_time=$(echo "$server_stats" | grep real | cut -d' ' -f2)
server_user_time=$(echo "$server_stats" | grep user | cut -d' ' -f2)
server_sys_time=$(echo "$server_stats" | grep sys | cut -d' ' -f2)

echo "Server CPU time: $(bc <<< "scale=2; $server_user_time + $server_sys_time") seconds"
echo "Server CPU load: $(bc <<< "scale=2; ($server_user_time + $server_sys_time) / $server_real_time * 100")%"
rm -f ./*.tmp