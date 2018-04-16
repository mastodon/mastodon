#!/bin/bash

# on system boot, and root have no rbenv installed,
#   after start-stop-daemon switched to current user, we have to init rbenv
if [ -d "$HOME/.rbenv/bin" ]; then
  PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
  eval "$(rbenv init -)"
elif [ -d "/usr/local/rbenv/bin" ]; then
  PATH="/usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH"
  eval "$(rbenv init -)"
elif [ -f /usr/local/rvm/scripts/rvm ]; then
  source /etc/profile.d/rvm.sh
elif [ -f "$HOME/.rvm/scripts/rvm" ]; then
  source "$HOME/.rvm/scripts/rvm"
fi

app=$1; config=$2; log=$3;
cd $app && exec bundle exec puma -C $config 2>&1 >> $log
