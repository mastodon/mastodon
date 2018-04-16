#!/bin/sh

# so master and this branch have the benchmark file in any case
cp bench/pack_symbols.rb bench/pack_symbols_tmp.rb

benchmark=""
current_branch=`git rev-parse --abbrev-ref HEAD`

for branch in master $current_branch; do
    echo "Testing branch $branch"
    git checkout $branch

    echo "Installing gem..."
    rake install

    echo "Running benchmark..."
    if [ "$benchmark" ]; then
        benchmark+=$'\n'
    fi
    benchmark+=$(viiite run bench/pack_symbols_tmp.rb)
    echo
done

rm bench/pack_symbols_tmp.rb

echo "$benchmark" | viiite report --regroup bench,reg_type,count,branch