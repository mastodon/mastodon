#!/usr/bin/env sh -e

for RUBY in 1.9.3 2.0.0 2.1 2.2
do
  for RAILS in 2.3.8 3.0.0 3.1.0 3.2.0 4.0.0 4.1.0 4.2.0
  do
    if [[ $RUBY -gt 1.9.3 && $RAILS -lt 4.0.0 ]]; then
      continue
    fi
    RBENV_VERSION=$RUBY ACTIVERECORD=$RAILS bundle && bundle exec rake
  done
done
