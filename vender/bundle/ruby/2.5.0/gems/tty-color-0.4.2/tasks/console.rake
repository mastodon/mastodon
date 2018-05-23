# encoding: utf-8

desc 'Load gem inside irb console'
task :console do
  require 'irb'
  require 'irb/completion'
  require File.join(__FILE__, '../../lib/tty-color')
  ARGV.clear
  IRB.start
end
task c: :console
