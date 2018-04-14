#!/bin/bash

if [[ $TRAVIS_OS_NAME != 'linux' ]]; then
  brew update
  # fix an issue with libtool on travis by reinstalling it
  brew uninstall libtool;
  brew install libtool dejagnu;
else
  sudo apt-get update
  sudo apt-get install dejagnu texinfo
  if [ "$HOST" = i386-pc-linux-gnu ] ; then
      sudo apt-get install gcc-multilib g++-multilib;
  fi
fi
