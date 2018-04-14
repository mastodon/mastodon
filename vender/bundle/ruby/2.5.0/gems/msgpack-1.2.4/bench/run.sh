#!/bin/sh

# prerequisites
# $ rbenv shell 2.2.1 (or jruby-x.x.x or ...)
# $ rake install

echo "pack"
viiite report --regroup bench,runs bench/pack.rb 
echo "unpack"
viiite report --regroup bench,runs bench/unpack.rb 
echo "pack log"
viiite report --regroup bench,runs bench/pack_log.rb 
echo "unpack log"
viiite report --regroup bench,runs bench/unpack_log.rb 
