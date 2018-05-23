# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

out, err = cmd.run(:ls, :out => 'ls.log')

puts "OUT>> #{out}"
puts "ERR>> #{err}"
