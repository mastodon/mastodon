# encoding: utf-8

require 'logger'
require 'tty-command'

logger = Logger.new('dev.log')

cmd = TTY::Command.new(output: logger, color: false)

cmd.run(:ls)
