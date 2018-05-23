# coding: utf-8

require 'benchmark/ips'
require 'stringio'
require_relative '../lib/tty-prompt'

input  = ::StringIO.new
output = ::StringIO.new
prompt  = TTY::Prompt.new(input: input, output: output)

Benchmark.ips do |r|

  r.report("Ruby #puts") do
    output.puts "What is your name?"
  end

  r.report("TTY::Prompt #ask") do
    prompt.ask("What is your name?")
  end
end

# Calculating -------------------------------------
#           Ruby #puts     34601 i/100ms
#     TTY::Prompt #ask        12 i/100ms
# -------------------------------------------------
#           Ruby #puts   758640.5 (±14.9%) i/s -    3736908 in   5.028562s
#     TTY::Prompt #ask       63.1 (±7.9%) i/s -        324 in   5.176857s
