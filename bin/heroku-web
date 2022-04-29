#!/bin/bash
if [ "$RUN_STREAMING" != "true" ]; then BIND=0.0.0.0 bundle exec puma -C config/puma.rb; else BIND=0.0.0.0 node ./streaming; fi