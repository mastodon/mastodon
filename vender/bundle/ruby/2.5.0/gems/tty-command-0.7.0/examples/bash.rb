# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

f = 'file'
if cmd.test("[ -f #{f} ]")
  puts "#{f} already exists!"
else
  cmd.run :touch, f
end
