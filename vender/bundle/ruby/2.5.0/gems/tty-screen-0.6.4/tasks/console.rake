# encoding: utf-8

desc 'Load gem inside irb console'
task :console do
  require 'irb'
  require 'irb/completion'
  require_relative '../lib/tty-screen'
  ARGV.clear
  IRB.start
end
task :c => :console
