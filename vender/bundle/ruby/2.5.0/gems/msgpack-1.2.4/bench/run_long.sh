#!/bin/sh

# prerequisites
# $ sudo apt-get install sysstat
# $ rbenv shell 2.2.1 (or jruby-x.x.x or ...)
# $ rake install

# 60 * 600 : 60*60 * 5[threads] * 2[bench]

ruby -v

echo "pack log long"
viiite report --regroup bench,threads bench/pack_log_long.rb &
sar -o pack_log_long.sar -r 60 600 > /dev/null 2>&1 &

declare -i i=0
while [ $i -lt 600 ]; do
    ps auxww | grep ruby | grep -v grep | awk '{print $5,$6;}' >> pack_log_long.mem.txt
    i=i+1
    sleep 60
done

sleep 120 # cool down

echo "unpack log long"
viiite report --regroup bench,threads bench/unpack_log_long.rb &
sar -o unpack_log_long.sar -r 60 600 > /dev/null 2>&1 &

i=0
while [ $i -lt 600 ]; do
    ps auxww | grep ruby | grep -v grep | awk '{print $5,$6;}' >> pack_log_long.mem.txt
    i=i+1
    sleep 60
done

