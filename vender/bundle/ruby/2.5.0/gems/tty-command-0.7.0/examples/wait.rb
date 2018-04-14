# encoding: utf-8

require 'tty-command'
require 'logger'

logger = Logger.new('dev.log')
cmd = TTY::Command.new

Thread.new do
  10.times do |i|
    sleep 1
    if i == 5
      logger << "error\n"
    else
      logger << "hello #{i}\n"
    end
  end
end


cmd.wait('tail -f dev.log', /error/)
