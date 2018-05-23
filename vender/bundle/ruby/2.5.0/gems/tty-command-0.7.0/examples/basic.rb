# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

out, err = cmd.run(:echo, 'hello world!')

puts "Result: #{out}"
