require 'benchmark/ips'
require 'tty-reader'

input = StringIO.new("abc\n")
output = StringIO.new
$stdin = input
reader = TTY::Reader.new(input, output)

Benchmark.ips do |x|
  x.report('gets') do
    input.rewind
    $stdin.gets
  end

  x.report('read_line') do
    input.rewind
    reader.read_line
  end

  x.compare!
end

# v0.1.0
#
# Calculating -------------------------------------
#                 gets     51729 i/100ms
#            read_line       164 i/100ms
# -------------------------------------------------
#                 gets  1955255.2 (±3.7%) i/s -    9776781 in   5.008004s
#            read_line     1215.1 (±33.1%) i/s -       5248 in   5.066569s
#
# Comparison:
#                 gets:  1955255.2 i/s
#            read_line:     1215.1 i/s - 1609.19x slower
