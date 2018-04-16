# encoding: utf-8
#
require 'memory_profiler'
require 'tty-command'

report = MemoryProfiler.report do
  cmd = TTY::Command.new(color: false)
  cmd.run("echo 'hello world!'")
end

report.pretty_print(to_file: 'memory_report.txt')
