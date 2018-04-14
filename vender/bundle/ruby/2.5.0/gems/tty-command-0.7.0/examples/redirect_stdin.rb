# encoding: utf-8

require 'tty-command'
require 'pathname'

cli = Pathname.new('examples/cli.rb')
cmd = TTY::Command.new

stdin = StringIO.new
stdin.puts "hello"
stdin.puts "world"
stdin.rewind

out, _ = cmd.run(cli, :in => stdin)

puts "#{out}"
