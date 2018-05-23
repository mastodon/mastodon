# encoding: utf-8

require 'tty-command'

cmd = TTY::Command.new

cmd.run("while test 1; do echo 'hello'; sleep 1; done", timeout: 5, signal: :KILL)
